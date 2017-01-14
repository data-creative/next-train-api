class Stop < ApplicationRecord
  belongs_to :schedule, :inverse_of => :stops
  has_many :stop_times, ->{ joins("JOIN stop_times ON stop_times.schedule_id = stops.schedule_id") }, :inverse_of => :stop, :primary_key => :guid, :foreign_key => :stop_guid, :dependent => :destroy

  validates_associated :schedule
  validates_presence_of :schedule_id, :guid, :name, :latitude, :longitude
  validates_inclusion_of :location_code, :in => [0,1], :allow_nil => true
  validates_inclusion_of :wheelchair_code, :in => [0,1,2], :allow_nil => true
  validates_uniqueness_of :guid, :scope => :schedule_id

  def self.active
    joins(:schedule).where(:schedules => {:active => true})
  end

  LOCATION_CLASSIFICATIONS = {
    0 => {name:"Stop", description:"A location where passengers board or disembark from a transit vehicle."},
    1 => {name:"Station", description:"A physical structure or area that contains one or more stop."}
  }

  def location_classification
    location_code.blank? ? LOCATION_CLASSIFICATIONS[0] : LOCATION_CLASSIFICATIONS[location_code]
  end

  WHEELCHAIR_CLASSIFICATIONS = {
    0 => {
      :nonparented => "Indicates that there is no accessibility information for the stop.",
      :parented => "The stop will inherit its wheelchair_boarding value from the parent station, if specified in the parent."
    },
    1 => {
      :nonparented => "Indicates that at least some vehicles at this stop can be boarded by a rider in a wheelchair.",
      :parented => "There exists some accessible path from outside the station to the specific stop / platform."
    },
    2 => {
      :nonparented => "Wheelchair boarding is not possible at this stop.",
      :parented => "There exists no accessible path from outside the station to the specific stop/platform."
    }
  }

  def wheelchair_boarding
    if parent_guid.blank?
      wheelchair_code.blank? ? WHEELCHAIR_CLASSIFICATIONS[0][:nonparented] : WHEELCHAIR_CLASSIFICATIONS[wheelchair_code][:nonparented]
    else
      wheelchair_code.blank? ? WHEELCHAIR_CLASSIFICATIONS[0][:parented] : WHEELCHAIR_CLASSIFICATIONS[wheelchair_code][:parented]
    end
  end
end
