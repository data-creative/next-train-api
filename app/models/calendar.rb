class Calendar < ApplicationRecord
  include DateFormatter

  belongs_to :schedule, :inverse_of => :calendars
  has_many :calendar_dates, ->(calendar){ where("calendar_dates.schedule_id = ?", calendar.schedule_id) }, :inverse_of => :calendar, :primary_key => :service_guid, :foreign_key => :service_guid, :dependent => :destroy
  has_many :trips, ->(calendar){ where("trips.schedule_id = ?", calendar.schedule_id) }, :inverse_of => :calendar, :primary_key => :service_guid, :foreign_key => :service_guid, :dependent => :destroy

  validates_associated :schedule
  validates_presence_of :schedule_id, :service_guid, :start_date, :end_date
  validates_inclusion_of :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :in => [true, false]
  validates_uniqueness_of :service_guid, :scope => :schedule_id

  # @param [String] date A date-string in YYYY-MM-DD format.
  def self.in_service_on(date)
    joins(:calendar_dates)
      .where("? BETWEEN start_date AND end_date", date)
      .where("? = true OR calendar_dates.exception_code = 1", day_of_week(date)) # handle additions
      .where("calendar_dates.exception_code <> 2 OR calendar_dates.exception_code IS NULL") # handle removals
  end
end
