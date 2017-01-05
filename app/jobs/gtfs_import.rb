require 'httparty'
require 'zip'

class GtfsImport < ApplicationJob
  queue_as :default

  # @param [Hash] options
  # @param [Hash] options [String] source_url Points to a hosted source of transit data in GTFS format (e.g. 'http://my-site.com/gtfs/some_feed.zip').
  # @param [Hash] options [String] destination_path Specifies where the data should be forcibly downloaded before it is loaded into the database.
  def initialize(options = {})
    @source_url = options[:source_url] || ENV.fetch('GTFS_SOURCE_URL', nil) || "http://www.shorelineeast.com/google_transit.zip"
    @destination_path = options[:destination_path] || "./tmp/google_transit.zip"
    @forced = (options[:forced] == true) || false
  end

  def perform
    hosted_schedule.destroy if forced?
    if hosted_schedule != active_schedule
      transform_and_load
      activate
    end
  end

  def forced?
    @forced == true
  end

  private

  def active_schedule
    Schedule.active
  end

  def hosted_schedule
    @schedule = Schedule.where({
      :source_url => @source_url,
      :published_at => headers["last-modified"].first.to_datetime,
      :content_length => headers["content-length"].first.to_i,
      :etag => headers["etag"].first.tr('"','')
    }).first_or_create!
  end

  def response
    @response ||= HTTParty.get(@source_url)
  end

  def headers
    response.headers.to_h
  end

  def transform_and_load
    FileUtils.rm_rf(@destination_path)

    File.open(@destination_path, "wb") do |zip_file|
      zip_file.write(response.body)
    end

    Zip::File.open(@destination_path) do |zip_file|
      parse_agency(zip_file) # GtfsImport::AgencyImport.new(zip_file).perform
      parse_calendar(zip_file) # GtfsImport::CalendarImport.new(zip_file).perform
      parse_calendar_dates(zip_file)
      parse_routes(zip_file)
      parse_stops(zip_file)
      parse_trips(zip_file)
      parse_stop_times(zip_file) #NOTE: depends on successful completion of #parse_stops and #parse_trips
    end
  end

  def activate
    @schedule.activate!
  end



































  # @param [String] str An exception code (e.g. "1", "2", or "1014")
  def parse_numeric(str)
    str.to_i unless str.blank?
  end

  # @param [String] str A boolean-convertable integer (either "0" or "1")
  def parse_bool(str)
    case str; when "0"; false; when "1"; true; end
  end

  # @param [String] str A latitude or longitude decimal (e.g. "41.29771887088102" or " -72.92673110961914")
  def parse_decimal(str)
    str.strip.to_f.round(8)
  end

  def read_file(zip_file, entry_name)
    entry = zip_file.entries.find{|entry| entry.name == entry_name }
    return entry.get_input_stream.read
  end




















  # @see https://developers.google.com/transit/gtfs/reference/agency-file
  def parse_agency(zip_file)
    results = read_file(zip_file, "agency.txt")
    CSV.parse(results, :headers => true) do |row|
      agency = Agency.where(:schedule_id => @schedule.id, :url => row["agency_url"]).first_or_initialize
      agency.update!({
        :guid => row["agency_id"],
        :name => row["agency_name"] || row[" agency_name"], # handle malformed header name
        :timezone => row["agency_timezone"],
        :phone => row["agency_phone"],
        :lang => row["agency_lang"]
      })
    end
  end

  # @see https://developers.google.com/transit/gtfs/reference/calendar-file
  def parse_calendar(zip_file)
    results = read_file(zip_file, "calendar.txt")
    CSV.parse(results, :headers => true) do |row|
      calendar = Calendar.where(:schedule_id => @schedule.id, :service_guid => row["service_id"]).first_or_initialize
      calendar.update({
        :monday => parse_bool(row["monday"]),
        :tuesday => parse_bool(row["tuesday"]),
        :wednesday => parse_bool(row["wednesday"]),
        :thursday => parse_bool(row["thursday"]),
        :friday => parse_bool(row["friday"]),
        :saturday => parse_bool(row["saturday"]),
        :sunday => parse_bool(row["sunday"]),
        :start_date => row["start_date"].to_date,
        :end_date => row["end_date"].to_date
      })
    end
  end

  # @see https://developers.google.com/transit/gtfs/reference/calendar_dates-file
  def parse_calendar_dates(zip_file)
    results = read_file(zip_file, "calendar_dates.txt")
    CSV.parse(results, :headers => true) do |row|
      calendar_date = CalendarDate.where({
        :schedule_id => @schedule.id,
        :service_guid => row["service_id"],
        :exception_date => row["date"].to_date
      }).first_or_initialize
      calendar_date.update!(:exception_code => parse_numeric(row["exception_type"]))
    end
  end

  # @see https://developers.google.com/transit/gtfs/reference/routes-file
  def parse_routes(zip_file)
    results = read_file(zip_file, "routes.txt")
    CSV.parse(results, :headers => true) do |row|
      route = Route.where(:schedule_id => @schedule.id, :guid => row["route_id"]).first_or_initialize
      route.update!({
        :agency_guid => row["agency_id"],
        :short_name => row["route_short_name"],
        :long_name => row["route_long_name"],
        :description => row["route_desc"],
        :code => parse_numeric(row["route_type"]),
        :url => row["url"],
        :color => row["color"],
        :text_color => row["text_color"],
      })
    end
  end

  # @see https://developers.google.com/transit/gtfs/reference/stops-file
  def parse_stops(zip_file)
    results = read_file(zip_file, "stops.txt")
    CSV.parse(results, :headers => true) do |row|
      stop = Stop.where(:schedule_id => @schedule.id, :guid => row["stop_id"]).first_or_initialize
      stop.update!({
        :short_name => row["stop_code"],
        :name => row["stop_name"],
        :description => row["stop_desc"],
        :latitude => parse_decimal(row["stop_lat"]),
        :longitude => parse_decimal(row["stop_lon"]),
        :zone_guid => row["zone_id"],
        :url => row["stop_url"],
        :location_code => parse_numeric(row["location_type"]),
        :parent_guid => row["parent_station"],
        :timezone => row["stop_timezone"],
        :wheelchair_code => parse_numeric(row["wheelchair_boarding"])
      })
    end
  end

  # @see https://developers.google.com/transit/gtfs/reference/trips-file
  def parse_trips(zip_file)
    results = read_file(zip_file, "trips.txt")
    CSV.parse(results, :headers => true) do |row|
      trip = Trip.where(:schedule_id => @schedule.id, :guid => row["trip_id"]).first_or_initialize
      trip.update!({
        :route_guid => row["route_id"],
        :service_guid => row["service_id"],
        :headsign => row["trip_headsign"],
        :short_name => row["trip_short_name"],
        :direction_code => parse_numeric(row["direction_id"]),
        :block_guid => row["block_id"],
        :shape_guid => row["shape_id"],
        :wheelchair_code => parse_numeric(row["wheelchair_accessible"]),
        :bicycle_code => parse_numeric(row["bikes_allowed"])
      })
    end
  end

  # @see https://developers.google.com/transit/gtfs/reference/stop_times-file
  def parse_stop_times(zip_file)
    results = read_file(zip_file, "stop_times.txt")
    CSV.parse(results, :headers => true) do |row|
      stop_time = StopTime.where({
        :schedule_id => @schedule.id,
        :trip_guid => row["trip_id"],
        :stop_guid => row["stop_id"],
      }).first_or_initialize

      # tracking a potential issue with the gtfs data...
      # there are sequential stop_times which share a composite key but differ in sequence.
      # @see https://gist.github.com/s2t2/0d2929e0ecaba85823e1314935e7941e
      # consider importing all records and adding stop_sequence to the composite key.
      if stop_time.persisted?
        Rails.logger.info{ "UNEXPECTED STOP TIME #{stop_time.trip_guid}-#{stop_time.stop_guid} (#{stop_time.stop_sequence} vs #{row['stop_sequence']})" }
        raise UnexpectedStopTime.new(row.to_h) unless stop_time.stop_sequence + 1 == row.to_h['stop_sequence'].to_i
        stop_time.update!(:departure_time => row["departure_time"], :stop_sequence => row["stop_sequence"].to_i)
      else
        stop_time.update!({
          :stop_sequence => row["stop_sequence"].to_i,
          :arrival_time => row["arrival_time"],
          :departure_time => row["departure_time"],
          :headsign => row["stop_headsign"],
          :pickup_code => parse_numeric(row["pickup_type"]),
          :dropoff_code => parse_numeric(row["drop_off_type"]),
          :distance => row["shape_dist_traveled"],
          :code => parse_numeric(row["timepoint"])
        })
      end
    end
  end
  class UnexpectedStopTime < StandardError ; end












end
