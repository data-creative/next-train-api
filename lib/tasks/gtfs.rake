namespace :gtfs do
  desc "Check hosted schedule and import if necessary."
  task import: :environment do
    GtfsImport.new.perform
  end

  desc "Import hosted schedule regardless of necessity."
  task force_import: :environment do
    GtfsImport.new(destructive: true).perform
  end
end
