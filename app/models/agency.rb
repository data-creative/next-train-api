class Agency < ApplicationRecord
  belongs_to :schedule, :inverse_of => :agencies

  validates_associated :schedule
  validates_presence_of :schedule_id, :url, :name, :timezone
  validates_uniqueness_of :url, :scope => :schedule_id
  validates_uniqueness_of :guid, :scope => :schedule_id
end
