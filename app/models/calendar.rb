class Calendar < ApplicationRecord
  belongs_to :schedule, :inverse_of => :calendars

  validates_associated :schedule
  validates_presence_of :service_id, :start_date, :end_date
  validates_inclusion_of :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :in => [true, false]
  validates :service_id, :uniqueness => {:scope => :schedule_id}
end