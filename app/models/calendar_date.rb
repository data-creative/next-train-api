class CalendarDate < ApplicationRecord
  belongs_to :schedule, :inverse_of => :calendar_dates

  validates_presence_of :service_id, :exception_date, :exception_code
  validates_inclusion_of :exception_code, :in => [1,2]
  validates :exception_date, :uniqueness => {:scope => [:schedule_id, :service_id]}
  ### validates :exception_code, :uniqueness => {:scope => [:schedule_id, :service_id, :exception_date]}

  def exception_type
    case exception_code; when 1; "Addition"; when 2; "Removal"; end
  end
end
