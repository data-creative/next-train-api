# @see https://developers.google.com/transit/gtfs/reference/routes-file
class CalendarsFileParser < FileParser
  def perform
    @logger.info{ "IMPORTING ROUTES" }
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
    @logger.info{ "... #{Route.count}" }
  end
end
