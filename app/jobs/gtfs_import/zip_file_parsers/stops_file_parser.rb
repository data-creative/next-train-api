# @see https://developers.google.com/transit/gtfs/reference/stops-file
class CalendarsFileParser < FileParser
  def perform
    @logger.info{ "IMPORTING STOPS" }
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
    @logger.info{ "... #{Stop.count}" }
  end
end
