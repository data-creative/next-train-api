class Route < ApplicationRecord
  belongs_to :schedule, :inverse_of => :routes
  has_many :trips, ->(route){ where("trips.schedule_id = ?", route.schedule_id) }, :inverse_of => :route, :primary_key => :guid, :foreign_key => :route_guid, :dependent => :destroy

  validates_associated :schedule
  validates_presence_of :schedule_id, :guid, :short_name, :long_name, :code
  validates_inclusion_of :code, :in => (0..7).to_a
  validates_uniqueness_of :guid, :scope => :schedule_id

  CLASSIFICATIONS = {
    0 => {name:"Tram, Streetcar, Light rail", description:"Any light rail or street level system within a metropolitan area."},
    1 => {name:"Subway, Metro", description:"Any underground rail system within a metropolitan area."},
    2 => {name:"Rail", description:"Used for intercity or long-distance travel."},
    3 => {name:"Bus", description:"Used for short- and long-distance bus routes."},
    4 => {name:"Ferry", description:"Used for short- and long-distance boat service."},
    5 => {name:"Cable car", description:"Used for street-level cable cars where the cable runs beneath the car."},
    6 => {name:"Gondola, Suspended cable car", description:"Typically used for aerial cable cars where the car is suspended from the cable."},
    7 => {name:"Funicular", description:"Any rail system designed for steep inclines."},
  }

  def classification
    CLASSIFICATIONS[code]
  end
end
