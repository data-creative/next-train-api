class Schedule < ApplicationRecord
  has_many :agencies, :inverse_of => :schedule
  has_many :calendars, :inverse_of => :schedule
  has_many :calendar_dates, :inverse_of => :schedule
  has_many :routes, :inverse_of => :schedule
  has_many :stops, :inverse_of => :schedule
  has_many :trips, :inverse_of => :schedule
  has_many :stop_times, :inverse_of => :schedule

  validates_presence_of :source_url, :published_at
  validates_inclusion_of :active, :in => [true, false]
  validates_uniqueness_of :published_at, :scope => :source_url
  validate :at_most_one_active_schedule

  def self.active
    where(:active => true).first
  end

  def activate!
    self.class.active.update!(:active => false) if self.class.active.present?
    update!(:active => true)
  end

  private

  def at_most_one_active_schedule
    if self.active? && self.class.active.present? && self.class.active.id != id
      errors.add(:active, "can only describe a single schedule. please deactivate other schedule(s) before attempting to activate this one.")
    end
  end
end
