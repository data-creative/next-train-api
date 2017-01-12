class Api::V1::TrainsResponse
  attr_reader :query, :received_at, :response_type, :errors, :date, :origin, :destination, :results

  # @example Api::V1::TrainsResponse.new({:date => "2017-01-11", :origin => "BRN", :destination => "NHV"})
  def initialize(query = {})
    @query = query
    @received_at = Time.zone.now
    @response_type = self.class.name
    @errors = []
    @origin = query[:origin]
    @destination = query[:destination]
    @date = query[:date]
    validate_query
    @results = generate_results
  end

  def to_h
    {
      :query => query,
      :received_at => received_at,
      :response_type => response_type,
      :errors => errors,
      :results => results
    }
  end

private

  def validate_query
    validate_origin
    validate_destination
    validate_date
  end # should add query validation error messages, if necessary

  def generate_results
    errors.empty? ? query_results : []
  end # should only return results if there are no query validation errors

  def validate_origin
    if origin.blank?
      errors << "Please specify an origin station abbreviation (e.g. 'BRN')."
    elsif !station_valid?(origin)
      errors << "Invalid origin station abbreviation."
    end
  end

  def validate_destination
    if destination.blank?
      errors << "Please specify a destination station abbreviation (e.g. 'NHV')."
    elsif !station_valid?(destination)
      errors << "Invalid destination station abbreviation."
    end
  end

  def station_valid?(abbrev)
    station_abbrevs.include?(abbrev)
  end

  def station_abbrevs
    ["NHV","ST","BRN","GUIL","MAD","CLIN","WES","OSB","NLC"] #TODO: if possible, avoid hard-coding while at the same time avoiding a database call
  end

  def validate_date
    if date.blank?
      errors << "Please specify a departure date (e.g. '#{Date.today}')."
    elsif !date_valid?
      errors << "Invalid departure date"
    end
  end

  def date_valid?
    y, m, d = date.strip.split("-")
    Date.valid_date?(y.to_i, m.to_i, d.to_i)
  end

  # @return [Array] a list of trains matching the given criteria
  def query_results
    #TODO: convert this query into ActiveRecord syntax and ensure protection from SQL injection
    sql = <<-SQL
      SELECT
        c.schedule_id
        ,c.service_guid
        ,t.guid AS trip_guid
        ,t.route_guid
        ,t.headsign AS trip_headsign
        ,st.stop_sequence
        ,st.stop_guid
        ,st.arrival_time
        ,st.departure_time
      FROM calendars c
      LEFT JOIN trips t ON t.service_guid = c.service_guid AND c.schedule_id = t.schedule_id
      JOIN (
        -- find all trips that include both stops and in the proper order/direction:
        SELECT
         trip_guid
         ,group_concat(stop_guid ORDER BY stop_sequence SEPARATOR ' > ') AS stops_in_sequence
        FROM stop_times
        GROUP BY trip_guid
        HAVING instr(stops_in_sequence, '#{origin}') <> 0 -- ensures origin station is included in the trip
          AND instr(stops_in_sequence, '#{destination}') <> 0 -- ensures destination station is included in the trip
          AND instr(stops_in_sequence, '#{origin}') < instr(stops_in_sequence, '#{destination}') -- ensures proper trip direction
        ORDER BY trip_guid
      ) trip_stops ON trip_stops.trip_guid = t.guid
      LEFT JOIN stop_times st ON st.trip_guid = t.guid AND st.schedule_id = t.schedule_id
      WHERE #{day_of_week} = TRUE
        AND '#{date}' BETWEEN c.start_date AND c.end_date
      ORDER BY t.guid, stop_sequence
    SQL

    raw_results = ActiveRecord::Base.connection.exec_query(sql)

    nested_results = raw_results.group_by{|h|
      h.select{|k,_| ["schedule_id", "route_guid", "service_guid", "trip_guid","trip_headsign"].include?(k) }
    }

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
  end # should prevent SQL injection

  def day_of_week
    Date.parse(date).strftime("%A").downcase
  end
end
