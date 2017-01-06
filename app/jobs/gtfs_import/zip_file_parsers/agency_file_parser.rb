require_relative "../zip_file_parser"

# @see https://developers.google.com/transit/gtfs/reference/agency-file
class AgencyFileParser < ZipFileParser
  def perform
    @logger.info{ "IMPORTING AGENCIES" }
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
    @logger.info{ "... #{Agency.count}" }
  end
end
