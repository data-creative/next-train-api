require 'httparty'
require 'zip'

require_relative "./gtfs_import/zip_file_parsers/agency_file_parser"
require_relative "./gtfs_import/zip_file_parsers/calendars_file_parser"
require_relative "./gtfs_import/zip_file_parsers/calendar_dates_file_parser"
require_relative "./gtfs_import/zip_file_parsers/routes_file_parser"
require_relative "./gtfs_import/zip_file_parsers/stops_file_parser"
require_relative "./gtfs_import/zip_file_parsers/stop_times_file_parser"
require_relative "./gtfs_import/zip_file_parsers/trips_file_parser"

class GtfsImport < ApplicationJob
  queue_as :default

  attr_reader :started_at, :ended_at, :schedule, :destination_path

  # @param [Hash] options
  # @param [Hash] options [String] source_url Points to a hosted source of transit data in GTFS format (e.g. 'http://my-site.com/gtfs/some_feed.zip').
  # @param [Hash] options [String] destination_path Specifies where the data should be forcibly downloaded before it is loaded into the database.
  def initialize(options = {})
    @source_url = options[:source_url] || ENV.fetch('GTFS_SOURCE_URL', nil) || "http://www.shorelineeast.com/google_transit.zip"
    @destination_path = options[:destination_path] || "./tmp/google_transit.zip"
    @forced = (options[:forced] == true) || false
    @logger = options[:logger] || (Rails.env.development? ? Logger.new(STDOUT) : Rails.logger )  #TODO: move me into ApplicationJob
    @started_at = nil #TODO: move me into ApplicationJob
    @ended_at = nil #TODO: move me into ApplicationJob
  end

  def perform
    @started_at = Time.zone.now #TODO: move me into ApplicationJob
    @logger.info{ "IMPORTING GTFS FEED FROM #{@source_url}" }
    hosted_schedule.destroy if forced?
    if hosted_schedule != active_schedule
      delete_destination
      extract
      transform_and_load
      activate
    end
    @ended_at = Time.zone.now #TODO: move me into ApplicationJob
    @logger.info{ "SUCCESSFUL AFTER #{(@ended_at - @started_at)} SECONDS" } #TODO: move me into ApplicationJob
  end #TODO: destroy existing data only after activating the new schedule only after data finishes loading

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

  def delete_destination
    FileUtils.rm_rf(@destination_path)
  end

  def extract
    File.open(@destination_path, "wb") do |zip_file|
      zip_file.write(response.body)
    end
  end

  def transform_and_load
    Zip::File.open(@destination_path) do |zip_file|
      options = {:zip_file => zip_file, :schedule => @schedule, :logger => @logger}
      AgencyFileParser.new(options).perform
      CalendarsFileParser.new(options).perform
      CalendarDatesFileParser.new(options).perform
      RoutesFileParser.new(options).perform #NOTE: likely to depend on successful completion of AgencyFileParser
      StopsFileParser.new(options).perform
      TripsFileParser.new(options).perform #NOTE: depends on successful completion of RoutesFileParser
      StopTimesFileParser.new(options).perform #NOTE: depends on successful completion of StopsFileParser and TripsFileParser
    end
  end

  def activate
    @logger.info{ "ACTIVATING SCHEDULE" }
    @schedule.activate!
  end
end
