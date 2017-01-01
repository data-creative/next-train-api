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
        # etc...
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
        :monday => calendar_day_boolean(row["monday"]),
        :tuesday => calendar_day_boolean(row["tuesday"]),
        :wednesday => calendar_day_boolean(row["wednesday"]),
        :thursday => calendar_day_boolean(row["thursday"]),
        :friday => calendar_day_boolean(row["friday"]),
        :saturday => calendar_day_boolean(row["saturday"]),
        :sunday => calendar_day_boolean(row["sunday"]),
        :start_date => row["start_date"].to_date,
        :end_date => row["end_date"].to_date
      })
    end
  end

  # @param [String] str a boolean-convertable integer: "0" or "1".
  def self.calendar_day_boolean(str)
    case str
    when "0"
      false
    when "1"
      true
    end
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
      calendar_date.update!(:exception_code => calendar_date_exception_code(row["exception_type"]))
    end
  end

  # @param [String] code an exception code: "1" or "2"
  def self.calendar_date_exception_code(code)
    case code; when "1"; 1; when "2"; 2; end
  end
end
