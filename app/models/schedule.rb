class Schedule < ApplicationRecord
  has_many :agencies, :inverse_of => :schedule
  has_many :calendars, :inverse_of => :schedule

  validates_presence_of :source_url, :published_at
  validates :published_at, :uniqueness => {:scope => :source_url}

  def self.latest
    order(:published_at => :desc).last
  end
end
