require 'httparty'
require 'zip'

class GtfsImport < ApplicationJob
  queue_as :default

  def self.perform(source_url: "http://www.shorelineeast.com/google_transit.zip", destination_path: "./tmp/google_transit.zip")
    system_schedule = TransitSchedule.latest

    response = HTTParty.get(source_url)
    headers = response.headers.to_h

    schedule = TransitSchedule.where(:source_url => source_url, :published_at => headers["last-modified"].first.to_datetime).first_or_create!
    schedule.update(:content_length => headers["content-length"].first.to_i, :etag => headers["etag"].first.tr('"',''))

    if schedule != system_schedule # schedule.published_at != system_schedule.published_at
      FileUtils.rm_rf(destination_path)

      File.open(destination_path, "wb") do |zip_file|
        zip_file.write(response.body)
      end # download

      Zip::File.open(destination_path) do |zip_file|
        zip_file.each do |entry|
          puts entry.name
        end
      end # parse
    end
  end
end
