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

  attr_reader :source_url, :destination_path, :destructive

  GTFS_SOURCE_URL = ENV.fetch('GTFS_SOURCE_URL', "OOPS")

  # @param [Hash] options
  # @param [Hash] options [String] source_url Points to a hosted source of transit data in GTFS format (e.g. 'http://my-site.com/gtfs/some_feed.zip').
  # @param [Hash] options [String] destination_path Specifies where the data should be forcibly downloaded before it is loaded into the database.
  def initialize(options = {})
    @source_url = options[:source_url] || GTFS_SOURCE_URL
    @destination_path = options[:destination_path] || "./tmp/google_transit.zip"
    @destructive = (options[:destructive] == true)
    super
    results[:source_url] = @source_url
    results[:destructive] = @destructive
  end

  def perform
    clock_in
    begin
      logger.info { "INSPECTING SCHEDULE HOSTED AT: #{source_url.upcase}" }

      if destructive?
        logger.info { "DESTROYING SCHEDULE: #{hosted_schedule.try(:serializable_hash)}" }
        hosted_schedule.try(:destroy)
      end

      results[:hosted_schedule] = hosted_schedule.try(:serializable_hash)
      #results[:active_schedule] = active_schedule.try(:serializable_hash)

      if schedule_verification?
        results[:schedule_verification] = true
        logger.info{ "VERIFIED EXISTING SCHEDULE" }
      else
        results[:new_schedule] = true
        logger.info { "FOUND NEW SCHEDULE: #{hosted_schedule.serializable_hash} \nPROCESSING..." }
        delete_destination
        extract
        transform_and_load
        hosted_schedule.activate!
        results[:schedule_activation] = true
        logger.info{ "ACTIVATED NEW SCHEDULE!" }
      end
    rescue => e
      handle_error(e)
    end

    clock_out
    send_results_email
    results
  end

  def destructive?
    destructive == true
  end

  def schedule_verification?
    hosted_schedule && hosted_schedule == active_schedule
  end

  def hosted_schedule
    Schedule.where({
      :source_url => source_url,
      :published_at => headers["last-modified"].first.to_datetime,
      :content_length => headers["content-length"].first.to_i,
      :etag => headers["etag"].first.tr('"','')
    }).first_or_create!
  end

  def active_schedule
    Schedule.active_one
  end

  def send_results_email
    logger.info { "SENDING SCHEDULE REPORT: #{results}" }
    report = GtfsImportMailer.schedule_report(results: results)
    Rails.env.development? ? report.deliver_now : report.deliver_later
    return true
  end

  private

  def response
    @response ||= HTTParty.get(source_url)
  end

  def headers
    response.headers.to_h
  end

  def delete_destination
    FileUtils.rm_rf(destination_path)
  end

  def extract
    File.open(destination_path, "wb") do |zip_file|
      zip_file.write(response.body)
    end
  end

  def transform_and_load
    Zip::File.open(destination_path) do |zip_file|
      options = {:zip_file => zip_file, :schedule => hosted_schedule, :logger => logger}
      AgencyFileParser.new(options).perform
      CalendarsFileParser.new(options).perform
      CalendarDatesFileParser.new(options).perform
      RoutesFileParser.new(options).perform #NOTE: likely to depend on successful completion of AgencyFileParser
      StopsFileParser.new(options).perform
      TripsFileParser.new(options).perform #NOTE: depends on successful completion of RoutesFileParser
      StopTimesFileParser.new(options).perform #NOTE: depends on successful completion of StopsFileParser and TripsFileParser
    end
  end

end
