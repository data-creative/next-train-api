class Calendar < ApplicationRecord
  include DateFormatter

  belongs_to :schedule, :inverse_of => :calendars

  has_many :calendar_dates, -> (calendar){ where("calendar_dates.schedule_id = ?", calendar.schedule_id) },
                                    :inverse_of => :calendar,
                                    :primary_key => :service_guid,
                                    :foreign_key => :service_guid,
                                    :dependent => :destroy

  #has_many :calendar_dates_join, -> { where("calendar_dates.schedule_id = calendars.schedule_id") },
  #                                  #:inverse_of => :calendar,
  #                                  :class_name => "CalendarDate",
  #                                  :primary_key => :service_guid,
  #                                  :foreign_key => :service_guid,
  #                                  :dependent => :destroy # use joins(:calendar_dates_join) instead of joins(:calendar_dates) because the latter will trigger an error about the association being instance-specific

  has_many :trips, ->(calendar){ where("trips.schedule_id = ?", calendar.schedule_id) }, :inverse_of => :calendar, :primary_key => :service_guid, :foreign_key => :service_guid, :dependent => :destroy

  validates_associated :schedule
  validates_presence_of :schedule_id, :service_guid, :start_date, :end_date
  validates_inclusion_of :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :in => [true, false]
  validates_uniqueness_of :service_guid, :scope => :schedule_id

  def self.active
    joins(:schedule).merge(Schedule.active)
  end

  def self.joins_trips
    joins("JOIN trips on trips.schedule_id = calendars.schedule_id AND trips.service_guid = calendars.service_guid")
  end

  # @param [String] date A date-string in YYYY-MM-DD format.
  def self.in_service_on(date)
    #active
    #  .where(day_of_week(date).to_sym => true)
    #  .where("? BETWEEN calendars.start_date AND calendars.end_date", date)

    unionable_selections = "schedules.id AS schedule_id, calendars.id AS calendar_id, calendars.service_guid"

    calendars = Calendar.active.where("? BETWEEN calendars.start_date AND calendars.end_date", date)

    calendars_in_service = calendars.where(day_of_week(date).to_sym => true).select(unionable_selections)

    calendars_added = calendars.joins("JOIN calendar_dates ON calendar_dates.service_guid = calendars.service_guid AND calendar_dates.schedule_id = calendars.schedule_id").where("calendar_dates.exception_date = ?", date).where("calendar_dates.exception_code = 1").select(unionable_selections)

    union = "#{calendars_in_service.to_sql} UNION #{calendars_added.to_sql}"

    calendars_removed = calendars.joins("JOIN calendar_dates ON calendar_dates.service_guid = calendars.service_guid AND calendar_dates.schedule_id = calendars.schedule_id").where("calendar_dates.exception_date = ?", date).where("calendar_dates.exception_code = 2").select("DISTINCT calendars.service_guid")

    Calendar.from("(#{union}) AS calendars").where("calendars.service_guid NOT IN (#{calendars_removed.to_sql})").order("calendars.service_guid")
  end
end
