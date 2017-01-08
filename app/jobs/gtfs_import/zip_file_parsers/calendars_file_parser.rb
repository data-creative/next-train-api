require_relative "../zip_file_parser"

# @see https://developers.google.com/transit/gtfs/reference/calendar-file
class CalendarsFileParser < ZipFileParser
  def perform
    @logger.info{ "IMPORTING CALENDARS" }
    results = read_file("calendar.txt")
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
    @logger.info{ "... #{Calendar.count}" }
  end
end
