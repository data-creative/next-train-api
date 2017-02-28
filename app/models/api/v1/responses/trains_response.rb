class Api::V1::TrainsResponse < Api::V1::Response
  attr_reader :date, :origin, :destination

  # @example Api::V1::TrainsResponse.new({:date => "2017-01-11", :origin => "BRN", :destination => "NHV"})
  def initialize(options = {})
    @origin = options[:origin]
    @destination = options[:destination]
    @date = options[:date]
    super(options)
  end

  def to_h
    {:query => query, :received_at => received_at, :response_type => response_type, :errors => errors, :results => results}
  end

private

  def validate_query
    validate_origin
    validate_destination
    validate_date
  end # should add query validation error messages, if necessary

  def validate_origin
    validate_station(origin, :origin)
  end

  def validate_destination
    validate_station(destination, :destination)
  end

  # @param [String] abbrev the station abbreviation
  # @param [Symbol] role either :origin or :destination
  def validate_station(abbrev, role)
    if abbrev.blank?
      errors << error_messages[role][:blank]
    elsif !station_valid?(abbrev)
      errors << error_messages[role][:invalid]
    end
  end

  def error_messages
    {
      :origin => {
        :blank => "Please specify an origin station abbreviation (e.g. 'BRN').",
        :invalid => "Invalid origin station abbreviation: #{origin}. Expecting one of: #{station_abbrevs}."
      },
      :destination => {
        :blank => "Please specify a destination station abbreviation (e.g. 'NHV').",
        :invalid => "Invalid destination station abbreviation: #{destination}. Expecting one of: #{station_abbrevs}."
      },
      :date => {
        :blank => "Please specify a departure date (e.g. '#{Date.today}').",
        :invalid => "Invalid departure date: #{date}."
      }
    }
  end

  def station_valid?(abbrev)
    station_abbrevs.include?(abbrev)
  end

  def station_abbrevs
    @station_abbrevs ||= Stop.active.map(&:guid).sort #TODO: to reduce response times, avoid calling the database, if possible, but how? hopefully not hard-coding the array and creating developer notifications when it needs to change. instead, can the array be cached somehow after successful schedule activation? yes, maybe reading and writing from a json file...
  end

  def validate_date
    if date.blank?
      errors << error_messages[:date][:blank]
    elsif !date_valid?
      errors << error_messages[:date][:invalid]
    end
  end

  def date_valid?
    y, m, d = date.strip.split("-")
    Date.valid_date?(y.to_i, m.to_i, d.to_i)
  end

  def day_of_week
    Date.parse(date).strftime("%A").downcase
  end

  def raw_results
    sql = <<-SQL

      -- TRIPS BELONGING TO ACTIVE SCHEDULES AND IN-SERVICE CALENDARS ...
      -- ... STOPPING IN ORDER FROM ORIGIN ('#{origin}') TO DESTINATION ('#{destination}') ...
      -- ... ON A GIVEN DAY ('#{day_of_week}', '#{date}')
      -- ... (~142 rows, row per stop_time, representing each of around 17 trips representing each of three calendars)
      SELECT
        trips.schedule_id
        ,trips.service_guid
        ,trips.route_guid
        ,trips.headsign AS trip_headsign
        ,stop_times.trip_guid
        ,stop_times.stop_guid
        ,stop_times.stop_sequence
        ,stop_times.arrival_time
        ,stop_times.departure_time

      FROM calendars
      JOIN (

        -- CALENDARS IN-SERVICE (~4 rows, one per calendar)
        SELECT u.schedule_id, u.calendar_id, u.service_guid
        FROM (

          -- CALENDARS NORMALLY IN-SERVICE (~3 rows, one per calendar)
          SELECT s.id AS schedule_id ,c.id AS calendar_id ,c.service_guid
          FROM schedules s
          JOIN calendars c ON c.schedule_id = s.id
          WHERE s.active = TRUE
            AND (c.#{day_of_week} = TRUE)
            AND ('#{date}' BETWEEN c.start_date AND c.end_date)

          UNION

          -- CALENDARS ADDED TO SERVICE (~2 rows, one per calendar)
          SELECT s.id AS schedule_id ,c.id AS calendar_id ,c.service_guid
          FROM schedules s
          JOIN calendars c ON c.schedule_id = s.id
          JOIN calendar_dates cd ON cd.service_guid = c.service_guid AND cd.schedule_id = c.schedule_id
          WHERE s.active = TRUE
            AND ('#{date}' BETWEEN c.start_date AND c.end_date)
            AND cd.exception_date = '#{date}'
            AND cd.exception_code = 1

        ) u
        WHERE u.service_guid NOT IN (

          -- CALENDARS REMOVED FROM SERVICE (~1 row, one per calender)
          SELECT DISTINCT c.service_guid
          FROM schedules s
          JOIN calendars c ON c.schedule_id = s.id
          JOIN calendar_dates cd ON cd.service_guid = c.service_guid AND cd.schedule_id = c.schedule_id
          WHERE s.active = TRUE
            AND ('#{date}' BETWEEN c.start_date AND c.end_date)
            AND cd.exception_date = '#{date}'
            AND cd.exception_code = 2

        )

      ) cals_in_service ON cals_in_service.calendar_id = calendars.id

      JOIN trips ON trips.schedule_id = calendars.schedule_id AND trips.service_guid = calendars.service_guid

      JOIN (

        -- TRIPS STOPPING IN ORDER
        SELECT trips.*
        FROM calendars
        JOIN trips ON trips.schedule_id = calendars.schedule_id AND trips.service_guid = calendars.service_guid
        JOIN (

          -- TRIPS WITH STOP SEQUENCES (~30 rows, one per trip)
          SELECT
           schedule_id
           ,trip_guid
           ,group_concat(stop_guid ORDER BY stop_sequence SEPARATOR ' > ') AS stops_in_sequence
          FROM stop_times
          JOIN schedules ON schedules.id = stop_times.schedule_id
          WHERE schedules.active = TRUE
          GROUP BY schedule_id, trip_guid
          HAVING instr(stops_in_sequence, '#{origin}') <> 0 -- INCLUDES ORIGIN STATION
            AND instr(stops_in_sequence, '#{destination}') <> 0 -- INCLUDES DESTINATION STATION
            AND instr(stops_in_sequence, '#{origin}') < instr(stops_in_sequence, '#{destination}') -- ORIGIN BEFORE DESTINATION
          ORDER BY trip_guid

        ) stops_by_trip ON stops_by_trip.schedule_id = trips.schedule_id AND stops_by_trip.trip_guid = trips.guid

      ) trips_stopping ON trips_stopping.id = trips.id

      JOIN stop_times ON stop_times.schedule_id = trips.schedule_id AND stop_times.trip_guid = trips.guid
      ORDER BY stop_times.stop_sequence

    SQL

    ActiveRecord::Base.connection.exec_query(sql)
  end

  def nested_results
    raw_results.group_by{|h|
      h.select{|k,_| ["schedule_id", "route_guid", "service_guid", "trip_guid", "trip_headsign"].include?(k) }
    }
  end

  def query_results
    formatted_results = nested_results.map{|trip, all_stops|
      origin_stop_time = all_stops.find{|stop| stop["stop_guid"] == origin }
      destination_stop_time = all_stops.find{|stop| stop["stop_guid"] == destination }
      stop_times = all_stops.map{|stop| stop.select{|k,_| ["stop_sequence","stop_guid","arrival_time","departure_time"].include?(k) } }

      trip.merge({
        :origin_departure => origin_stop_time["departure_time"],
        :destination_arrival => destination_stop_time["arrival_time"],
        :all_stop_times => stop_times.sort_by{|stop_time| stop_time["stop_sequence"].to_i }
      })
    }

    return formatted_results
  end
end
