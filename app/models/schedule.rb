class Schedule < ApplicationRecord
  has_many :agencies, :inverse_of => :schedule
  has_many :calendars, :inverse_of => :schedule
  has_many :calendar_dates, :inverse_of => :schedule
  has_many :routes, :inverse_of => :schedule
  has_many :stops, :inverse_of => :schedule
  has_many :trips, :inverse_of => :schedule
  has_many :stop_times, :inverse_of => :schedule

  validates_presence_of :source_url, :published_at
  validates_uniqueness_of :published_at, :scope => :source_url

  def self.latest
    order(:published_at => :desc).last
  end
end
