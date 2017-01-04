namespace :gtfs do
  desc "Check for an updated schedule and import it if necessary."
  task import: :environment do |t|
    GtfsImport.new.perform
  end
end
