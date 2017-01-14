class Calendar < ApplicationRecord
  belongs_to :schedule, :inverse_of => :calendars
  #TODO; has_many :calendar_dates ...
  has_many :trips, ->(calendar){ where("trips.schedule_id = ?", calendar.schedule_id) }, :inverse_of => :calendar, :primary_key => :service_guid, :foreign_key => :service_guid, :dependent => :destroy

  validates_associated :schedule
  validates_presence_of :schedule_id, :service_guid, :start_date, :end_date
  validates_inclusion_of :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :in => [true, false]
  validates_uniqueness_of :service_guid, :scope => :schedule_id

  # @param [String] str A date-string in YYYY-MM-DD format.
  def self.day_of_week(str)
    Date.parse(str).strftime("%A").downcase #> "wednesday"
  end

  # @param [String] str A date-string in YYYY-MM-DD format.
  def self.in_service_on(str)
    where("? BETWEEN start_date AND end_date", str).where((day_of_week(str)).to_sym => true)
  end
end
