class Calendar < ApplicationRecord
  belongs_to :schedule, :inverse_of => :calendars

  validates_associated :schedule
  validates_presence_of :schedule_id, :service_guid, :start_date, :end_date
  validates_inclusion_of :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :in => [true, false]
  validates_uniqueness_of :service_guid, :scope => :schedule_id

  # @param [String] str A date-string in YYYY-MM-DD format.
  def self.day_of_week(str)
    str.to_date.strftime("%A").downcase #> "wednesday"
  end

  # @param [String] str A date-string in YYYY-MM-DD format.
  def self.in_service_on(str)
    where("? BETWEEN start_date AND end_date", str).where((day_of_week(str)).to_sym => true)
  end
end
