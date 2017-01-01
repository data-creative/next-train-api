class Agency < ApplicationRecord
  belongs_to :schedule, :inverse_of => :agencies

  validates_associated :schedule
  validates_presence_of :url, :name, :timezone
  validates :url, :uniqueness => {:scope => :schedule_id}
end