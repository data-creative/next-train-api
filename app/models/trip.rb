class Trip < ApplicationRecord
  belongs_to :schedule, :inverse_of => :trips
  belongs_to :route, :inverse_of => :trips, :primary_key => :guid, :foreign_key => :route_guid
  belongs_to :calendar, :inverse_of => :trips, :primary_key => :service_guid, :foreign_key => :service_guid
  has_many :stop_times, ->(trip){ where("stop_times.schedule_id = ?", trip.schedule_id) }, :inverse_of => :trip, :primary_key => :guid, :foreign_key => :trip_guid, :dependent => :destroy

  validates_associated :schedule
  validates_associated :route
  validates_associated :calendar
  validates_presence_of :schedule_id, :guid, :route_guid, :service_guid
  validates_inclusion_of :direction_code, :in => [0,1], :allow_nil => true
  validates_inclusion_of :wheelchair_code, :in => [0,1,2], :allow_nil => true
  validates_inclusion_of :bicycle_code, :in => [0,1,2], :allow_nil => true
  validates_uniqueness_of :guid, :scope => :schedule_id
end
