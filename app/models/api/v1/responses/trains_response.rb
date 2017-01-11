class Api::V1::TrainsResponse
  attr_reader :date, :origin, :destination

  # @example Api::V1::TrainsResponse.new({:date => "2017-01-11", :origin => "BRN", :destination => "NHV"})
  def initialize(options = {})
    @date = options[:date]
    @origin = options[:origin]
    @destination = options[:destination]
  end

  # @return [Array] a list of trains matching the given criteria
  def results
    return @results if @results

    #TODO: convert this query into ActiveRecord syntax and ensure protection from SQL injection
    sql_query = <<-SQL
      SELECT
        c.schedule_id
        ,c.service_guid
        ,t.guid AS trip_guid
        ,t.route_guid
        ,t.headsign AS trip_headsign
        ,st.stop_sequence
        ,st.stop_guid
        ,st.arrival_time
        ,st.departure_time
      FROM calendars c
      LEFT JOIN trips t ON t.service_guid = c.service_guid AND c.schedule_id = t.schedule_id
      JOIN (
        -- find all trips that include both stops and in the proper order/direction:
        SELECT
         trip_guid
         ,group_concat(stop_guid ORDER BY stop_sequence SEPARATOR ' > ') AS stops_in_sequence
        FROM stop_times
        GROUP BY trip_guid
        HAVING instr(stops_in_sequence, '#{origin}') <> 0 -- ensures origin station is included in the trip
          AND instr(stops_in_sequence, '#{destination}') <> 0 -- ensures destination station is included in the trip
          AND instr(stops_in_sequence, '#{origin}') < instr(stops_in_sequence, '#{destination}') -- ensures proper trip direction
        ORDER BY trip_guid
      ) trip_stops ON trip_stops.trip_guid = t.guid
      LEFT JOIN stop_times st ON st.trip_guid = t.guid AND st.schedule_id = t.schedule_id
      WHERE #{day_of_week} = TRUE
        AND '#{date}' BETWEEN c.start_date AND c.end_date
      ORDER BY t.guid, stop_sequence
    SQL

    query_results = ActiveRecord::Base.connection.exec_query(sql_query)

    nested_results = query_results.group_by{|h|
      h.select{|k,v| ["schedule_id", "route_guid", "service_guid", "trip_guid","trip_headsign"].include?(k) }
    }

    formatted_results = nested_results.map{|h, arr|
      origin_stop_time = arr.find{|h| h["stop_guid"] == origin }
      destination_stop_time = arr.find{|h| h["stop_guid"] == destination }
      stop_times = arr.map{|h| h.select{|k,v| ["stop_sequence","stop_guid","arrival_time","departure_time"].include?(k) } }

      h.merge({
        :origin_departure => origin_stop_time["departure_time"],
        :destination_arrival => destination_stop_time["arrival_time"],
        :all_stop_times => stop_times.sort_by{|h| h["stop_sequence"].to_i }
      })
    }

    @results = formatted_results
  end

private

  def day_of_week
    Date.parse(date).strftime("%A").downcase
  end
end
