require 'rails_helper'
require 'rake'

RSpec.describe "gtfs" do
  before(:all) do
     Rake.application.rake_require('../../lib/tasks/gtfs')
     Rake::Task.define_task(:environment) # gets rid of... RuntimeError: Don't know how to build task 'environment' (see --tasks)
  end

  describe ":import" do
    it "should perform a GtfsImport" do
      expect_any_instance_of(GtfsImport).to receive(:perform)
      Rake.application["gtfs:import"].invoke
    end
  end

  describe ":force_import" do
    #before(:all) do
    #  RSpec.configure do |config|
    #    config.warnings = false
    #  end
    #end # this does not suppress warning message as expected

    #after(:all) do
    #  RSpec.configure do |config|
    #    config.warnings = true
    #  end
    #end

    it "should perform a desctructive GtfsImport" do
      #expect_any_instance_of(GtfsImport).to receive(:initialize).with(hash_including(destructive: true)) # warns... "warning: removing `initialize' may cause serious problems"
      expect_any_instance_of(GtfsImport).to receive(:perform)
      Rake.application["gtfs:force_import"].invoke
    end
  end
end
