require_relative "../zip_file_parser"

# @see https://developers.google.com/transit/gtfs/reference/calendar_dates-file
class CalendarDatesFileParser < ZipFileParser
  def perform
    @logger.info{ "IMPORTING CALENDAR DATES" }
    results = read_file("calendar_dates.txt")
    CSV.parse(results, :headers => true) do |row|
      calendar_date = CalendarDate.where({
        :schedule_id => @schedule.id,
        :service_guid => row["service_id"],
        :exception_date => row["date"].to_date
      }).first_or_initialize
      calendar_date.update!(:exception_code => parse_numeric(row["exception_type"]))
    end
    @logger.info{ "... #{CalendarDate.count}" }
  end
end
