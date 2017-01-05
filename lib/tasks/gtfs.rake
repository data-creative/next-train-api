namespace :gtfs do
  desc "Check hosted schedule and import if necessary."
  task import: :environment do |t|
    GtfsImport.new.perform
  end

  desc "Import hosted schedule regardless of necessity."
  task force_import: :environment do |t|
    GtfsImport.new(:forced => true).perform
  end
end
