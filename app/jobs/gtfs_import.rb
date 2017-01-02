require 'httparty'
require 'zip'

class GtfsImport < ApplicationJob
  queue_as :default

  def initialize(options = {})
    @source_url = options[:source_url] || "http://www.shorelineeast.com/google_transit.zip"
    @destination_path = options[:destination_path] || "./tmp/google_transit.zip"
  end

  def perform
    system_schedule = Schedule.latest

    response = HTTParty.get(@source_url)
    headers = response.headers.to_h

    @schedule = Schedule.where(:source_url => @source_url, :published_at => headers["last-modified"].first.to_datetime).first_or_create!
    @schedule.update!(:content_length => headers["content-length"].first.to_i, :etag => headers["etag"].first.tr('"',''))

    if @schedule != system_schedule
      FileUtils.rm_rf(@destination_path)

      File.open(@destination_path, "wb") do |zip_file|
        zip_file.write(response.body)
      end

      Zip::File.open(@destination_path) do |zip_file|
        @zip_file = zip_file
        parse_agency # GtfsImport::AgencyParse.new(zip_file).perform
        parse_calendar # GtfsImport::CalendarParse.new(zip_file).perform
        parse_calendar_dates
        parse_routes
        parse_stops
        #parse_trips
        parse_stop_times # depends on successful completion of #parse_stops and #parse_trips
      end
    end
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

  private

  def read_file(entry_name)
    entry = @zip_file.entries.find{|entry| entry.name == entry_name }
    return entry.get_input_stream.read
  end

  # @see https://developers.google.com/transit/gtfs/reference/agency-file
  def parse_agency
    results = read_file("agency.txt")
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
  def parse_calendar
    results = read_file("calendar.txt")
    CSV.parse(results, :headers => true) do |row|
      calendar = Calendar.where(:schedule_id => @schedule.id, :service_id => row["service_id"]).first_or_initialize
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
  def parse_calendar_dates
    results = read_file("calendar_dates.txt")
    CSV.parse(results, :headers => true) do |row|
      calendar_date = CalendarDate.where({
        :schedule_id => @schedule.id,
        :service_id => row["service_id"],
        :exception_date => row["date"].to_date
      }).first_or_initialize
      calendar_date.update!(:exception_code => parse_numeric(row["exception_type"]))
    end
  end

  # @see https://developers.google.com/transit/gtfs/reference/routes-file
  def parse_routes
    results = read_file("routes.txt")
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
  def parse_stops
    results = read_file("stops.txt")
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

  # @see https://developers.google.com/transit/gtfs/reference/stop_times-file
  def parse_stop_times
    results = read_file("stop_times.txt")
    CSV.parse(results, :headers => true) do |row|
      stop_time = StopTime.where({
        :schedule_id => @schedule.id,
        :trip_guid => row["trip_id"],
        :stop_guid => row["stop_id"],
      }).first_or_initialize

      # tracking a potential issue with the gtfs data...
      # there are sequential stop_times which share a composite key but differ in sequence.
      # consider adding stop_sequence to the composite key.
      if stop_time.persisted?
        #puts "UNEXPECTED STOP TIME #{stop_time.trip_guid}-#{stop_time.stop_guid} (#{stop_time.stop_sequence} vs #{row['stop_sequence']})"
        raise UnexpectedStopTime.new(row.to_h) unless stop_time.stop_sequence + 1 == row.to_h['stop_sequence'].to_i
      end

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
  class UnexpectedStopTime < StandardError ; end

end
