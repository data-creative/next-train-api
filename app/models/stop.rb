class Stop < ApplicationRecord
  belongs_to :schedule, :inverse_of => :stops

  validates_associated :schedule
  validates_presence_of :schedule_id, :guid, :name, :latitude, :longitude
  validates_inclusion_of :location_code, :in => [0,1], :allow_nil => true
  validates_inclusion_of :wheelchair_code, :in => [0,1,2], :allow_nil => true
  validates :guid, :uniqueness => {:scope => :schedule_id}

  LOCATION_CLASSIFICATIONS = {
    0 => {name:"Tram, Streetcar, Light rail", description:"Any light rail or street level system within a metropolitan area."},
    1 => {name:"Subway, Metro", description:"Any underground rail system within a metropolitan area."}
  }

  def location_classification
    LOCATION_CLASSIFICATIONS[location_code]
  end
end
