require 'httparty'
require 'zip'

class GtfsImport < ApplicationJob
  queue_as :default

  def self.perform(source_url: "http://www.shorelineeast.com/google_transit.zip", destination_path: "./tmp/google_transit.zip")
    system_schedule = Schedule.latest

    response = HTTParty.get(source_url)
    headers = response.headers.to_h

    @schedule = Schedule.where(:source_url => source_url, :published_at => headers["last-modified"].first.to_datetime).first_or_create!
    @schedule.update!(:content_length => headers["content-length"].first.to_i, :etag => headers["etag"].first.tr('"',''))

    if @schedule != system_schedule
      FileUtils.rm_rf(destination_path)

      File.open(destination_path, "wb") do |zip_file|
        zip_file.write(response.body)
      end

      Zip::File.open(destination_path) do |zip_file|
        @zip_file = zip_file
        parse_agency
        parse_calendar
        parse_calendar_dates
        parse_routes
        #parse_stops
        #parse_stop_times
        #parse_trips
      end
    end
  end

  def self.read_file(entry_name)
    entry = @zip_file.entries.find{|entry| entry.name == entry_name }
    return entry.get_input_stream.read
  end

  # @see https://developers.google.com/transit/gtfs/reference/agency-file
  def self.parse_agency
    results = read_file("agency.txt")
    CSV.parse(results, :headers => true) do |row|
      agency = Agency.where(:schedule_id => @schedule.id, :url => row["agency_url"]).first_or_initialize
      agency.update!({
        :abbrev => row["agency_id"],
        :name => row["agency_name"] || row[" agency_name"], # handle malformed header name
        :timezone => row["agency_timezone"],
        :phone => row["agency_phone"],
        :lang => row["agency_lang"]
      })
    end
  end

  # @see https://developers.google.com/transit/gtfs/reference/calendar-file
  def self.parse_calendar
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

  # @param [String] str a boolean-convertable integer: "0" or "1".
  def self.parse_bool(str)
    case str; when "0"; false; when "1"; true; end
  end

  # @see https://developers.google.com/transit/gtfs/reference/calendar_dates-file
  def self.parse_calendar_dates
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

  # @param [String] str an exception code like "1" or "2"
  def self.parse_numeric(str)
    str.to_i unless str.blank?
  end

  # @see https://developers.google.com/transit/gtfs/reference/routes-file
  def self.parse_routes
    results = read_file("routes.txt")
    CSV.parse(results, :headers => true) do |row|
      route = Route.where(:schedule_id => @schedule.id, :guid => row["route_id"]).first_or_initialize
      route.update!({
        :agency_abbrev => row["agency_id"],
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
end
