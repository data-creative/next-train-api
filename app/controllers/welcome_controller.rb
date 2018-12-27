class WelcomeController < ApplicationController

  def index
    @source_url = ENV.fetch("GTFS_SOURCE_URL", "OOPS, please set the GTFS_SOURCE_URL.")
    @active_schedule = Schedule.active_one
  end

end
