require_relative "../zip_file_parser"

# @see https://developers.google.com/transit/gtfs/reference/stop_times-file
class StopTimesFileParser < ZipFileParser
  def perform
    @logger.info{ "IMPORTING STOP TIMES" }
    results = read_file("stop_times.txt")
    CSV.parse(results, :headers => true) do |row|
      stop_time = StopTime.where({
        :schedule_id => @schedule.id,
        :trip_guid => row["trip_id"],
        :stop_guid => row["stop_id"],
      }).first_or_initialize

      # tracking a potential issue with the gtfs data...
      # there are sequential stop_times which share a composite key but differ in sequence.
      # @see https://gist.github.com/s2t2/0d2929e0ecaba85823e1314935e7941e
      # consider importing all records and adding stop_sequence to the composite key.
      # FYI: if a previous import has failed, this condition will trigger erroneously, so consider running a forced import to destroy the persisted versions
      if stop_time.persisted?
        if stop_time.stop_sequence + 1 == row.to_h['stop_sequence'].to_i
          @logger.warn{ "... CONSOLIDATING STOP TIMES #{stop_time.trip_guid}-#{stop_time.stop_guid} (#{stop_time.stop_sequence} vs #{row['stop_sequence']})" }
          stop_time.update!(:departure_time => row["departure_time"], :stop_sequence => row["stop_sequence"].to_i)
        else
          raise UnexpectedStopTime.new(row.to_h)
        end
      else
        stop_time.update!({
          :stop_sequence => row["stop_sequence"].to_i,
          :arrival_time => row["arrival_time"],
          :departure_time => row["departure_time"],
          :headsign => row["stop_headsign"],
          :pickup_code => parse_numeric(row["pickup_type"]),
          :dropoff_code => parse_numeric(row["drop_off_type"]),
          :distance => row["shape_dist_traveled"],
          :code => parse_numeric(row["timepoint"])
        })
      end
    end
    @logger.info{ "... #{StopTime.count}" }
  end

  class UnexpectedStopTime < StandardError ; end
end
