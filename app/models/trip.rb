class Trip < ApplicationRecord
  belongs_to :schedule, :inverse_of => :trips
  belongs_to :route, :inverse_of => :trips, :primary_key => :guid, :foreign_key => :route_guid
  belongs_to :calendar, :inverse_of => :trips, :primary_key => :service_guid, :foreign_key => :service_guid
  has_many :stop_times, ->(trip){ where("stop_times.schedule_id = ?", trip.schedule_id) }, :inverse_of => :trip, :primary_key => :guid, :foreign_key => :trip_guid, :dependent => :destroy

  #has_many :joined_stop_times, ->{ where("stop_times.schedule_id = trips.schedule_id") },
  #          #:inverse_of => :trip,
  #          :class_name => "StopTime",
  #          :primary_key => :guid,
  #          :foreign_key => :trip_guid,
  #          :dependent => :destroy # use joins(:joined_stop_times) instead of joins(:stop_times) because the latter will trigger an error about the association being instance-specific

  validates_associated :schedule
  validates_associated :route
  validates_associated :calendar
  validates_presence_of :schedule_id, :guid, :route_guid, :service_guid
  validates_inclusion_of :direction_code, :in => [0,1], :allow_nil => true
  validates_inclusion_of :wheelchair_code, :in => [0,1,2], :allow_nil => true
  validates_inclusion_of :bicycle_code, :in => [0,1,2], :allow_nil => true
  validates_uniqueness_of :guid, :scope => :schedule_id

  #def self.joins_cal
  #  joins("JOIN calendars on trips.schedule_id = calendars.schedule_id AND trips.service_guid = calendars.service_guid")
  #end

  # @param [String] date A date-string in YYYY-MM-DD format.
  def self.in_service_on(date)
    #joins_cal.merge(Calendar.in_service_on(date)).select("calendars.schedule_id ,calendars.calendar_id ,calendars.service_guid
    #                                                          ,trips.guid AS trip_guid ,trips.route_guid ,trips.headsign".squish)

    Calendar.in_service_on(date).joins_trips.select("calendars.schedule_id ,calendars.calendar_id ,calendars.service_guid ,trips.guid AS trip_guid ,trips.route_guid ,trips.headsign")
  end

  def self.traveling_in_direction(from:, to:)
    origin, destination = from, to

    trip_guids = StopTime.group("trip_guid")
      .having("instr(stops_in_sequence, ?) <> 0", origin) # -- ensures origin station is included in the trip
      .having("instr(stops_in_sequence, ?) <> 0", destination) # -- ensures destination station is included in the trip
      .having("instr(stops_in_sequence, ?) < instr(stops_in_sequence, ?)", origin, destination) # -- ensures proper trip direction
      .select("trip_guid ,group_concat(stop_guid ORDER BY stop_sequence SEPARATOR ' > ') AS stops_in_sequence")

    joins("JOIN (#{trip_guids.to_sql}) trips_in_direction ON trips_in_direction.trip_guid = trips.guid")
  end
end
