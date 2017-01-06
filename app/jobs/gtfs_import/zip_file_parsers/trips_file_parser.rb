# @see https://developers.google.com/transit/gtfs/reference/trips-file
class TripsFileParser < FileParser
  def perform
    @logger.info{ "IMPORTING TRIPS" }
    results = read_file("trips.txt")
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
    @logger.info{ "... #{CalendarDate.count}" }
  end
end
