require 'rails_helper'
require 'rake'

RSpec.describe "gtfs:import" do
  before(:all) do
     Rake.application.rake_require('../../lib/tasks/gtfs')
     Rake::Task.define_task(:environment) # gets rid of... RuntimeError: Don't know how to build task 'environment' (see --tasks)
  end

  it "should perform a GtfsImport" do
    expect_any_instance_of(GtfsImport).to receive(:perform)
    Rake.application["gtfs:import"].invoke
  end
end
