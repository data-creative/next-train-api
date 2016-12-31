class TransitSchedule < ApplicationRecord
  def self.latest
    order(:published_at => :desc).last
  end
end
