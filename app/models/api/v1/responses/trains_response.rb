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

  def raw_results
    Trip.stopping_in_sequence(:from => origin, :to => destination)
      .joins(:calendar).merge(Calendar.in_service_on(date))
      .joins(:schedule).merge(Schedule.is_active)
      .joins(:stop_times)
      .select("calendars.schedule_id
        ,schedules.published_at
        ,calendars.service_guid
        ,trips.guid AS trip_guid ,trips.route_guid ,trips.headsign AS trip_headsign
        ,stop_times.stop_sequence ,stop_times.stop_guid ,stop_times.arrival_time ,stop_times.departure_time"
      )
  end #TODO: add or subtract additional calendar dates from the service

  def nested_results
    raw_results.map{|row| row.serializable_hash }.group_by{|h| h.select{|k,_| ["schedule_id","route_guid","service_guid","trip_guid","trip_headsign"].include?(k) } }
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
