class Train < ApplicationRecord

  # @param [String] date observes "YYYY-MM-DD" format
  def self.departing_on(date)
    where("DATE(origin_departure) = ?", date)
  end

  def self.from_station(station_abbrev)
    where(:origin => station_abbrev)
  end

  def self.to_station(station_abbrev)
    where(:destination => station_abbrev)
  end
end
