class CalendarDate < ApplicationRecord
  belongs_to :schedule, :inverse_of => :calendar_dates
  #TODO; belongs_to :calendar ...

  validates_associated :schedule
  validates_presence_of :schedule_id, :service_guid, :exception_date, :exception_code
  validates_inclusion_of :exception_code, :in => [1,2]
  validates_uniqueness_of :exception_date, :scope => [:schedule_id, :service_guid]

  def exception_type
    case exception_code; when 1; "Addition"; when 2; "Removal"; end
  end
end
