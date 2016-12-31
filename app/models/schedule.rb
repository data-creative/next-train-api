class Schedule < ApplicationRecord
  has_many :agencies, :inverse_of => :schedule

  def self.latest
    order(:published_at => :desc).last
  end
end
