class CalendarDate < ApplicationRecord
  belongs_to :schedule, :inverse_of => :calendar_dates
  belongs_to :calendar, :inverse_of => :calendar_dates, :primary_key => :service_guid, :foreign_key => :service_guid

  validates_associated :schedule
  validates_associated :calendar
  validates_presence_of :schedule_id, :service_guid, :exception_date, :exception_code
  validates_inclusion_of :exception_code, :in => [1,2]
  validates_uniqueness_of :exception_date, :scope => [:schedule_id, :service_guid]

  def exception_type
    case exception_code; when 1; "Addition"; when 2; "Removal"; end
  end
end
