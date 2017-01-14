class StopTime < ApplicationRecord
  belongs_to :schedule, :inverse_of => :stop_times
  belongs_to :stop, :inverse_of => :stop_times, :primary_key => :guid, :foreign_key => :stop_guid
  belongs_to :trip, :inverse_of => :stop_times, :primary_key => :guid, :foreign_key => :trip_guid

  validates_associated :schedule
  validates_associated :stop
  validates_associated :trip
  validates_presence_of :schedule_id, :stop_guid, :trip_guid, :arrival_time, :departure_time, :stop_sequence
  validates_inclusion_of :code, :in => [0,1], :allow_nil => true
  validates_inclusion_of :pickup_code, :in => [0,1,2,3], :allow_nil => true
  validates_inclusion_of :dropoff_code, :in => [0,1,2,3], :allow_nil => true
  validates_uniqueness_of :stop_guid, :scope => [:schedule_id, :trip_guid]

  # @param [String] from The origin station abbreviation
  # @param [String] to The destination station abbreviation
  def self.trips_stopping_in_sequence(from:, to:)
    group(:trip_guid)
      .having("instr(stops_in_sequence, ?) <> 0 AND instr(stops_in_sequence, ?) <> 0", from, to)
      .having("instr(stops_in_sequence, ?) < instr(stops_in_sequence, ?)", from, to)
      .select("trip_guid
        ,group_concat(stop_guid ORDER BY stop_sequence SEPARATOR ' > ') AS stops_in_sequence
        ,count(DISTINCT stop_guid) AS stop_count".squish
      )
  end
end
