class Trip < ApplicationRecord
  belongs_to :schedule, :inverse_of => :trips
  belongs_to :route, :inverse_of => :trips, :primary_key => :guid, :foreign_key => :route_guid
  #belongs_to :service, :inverse_of => :trips
  has_many :stop_times, :inverse_of => :trip, :primary_key => :guid, :foreign_key => :trip_guid, :dependent => :destroy

  validates_associated :schedule
  validates_associated :route
  #validates_associated :service
  validates_presence_of :schedule_id, :guid, :route_guid, :service_guid
  validates_inclusion_of :direction_code, :in => [0,1], :allow_nil => true
  validates_inclusion_of :wheelchair_code, :in => [0,1,2], :allow_nil => true
  validates_inclusion_of :bicycle_code, :in => [0,1,2], :allow_nil => true
  validates_uniqueness_of :guid, :scope => :schedule_id
end
