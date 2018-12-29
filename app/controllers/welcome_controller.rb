class WelcomeController < ApplicationController

  def index
    @source_url = ENV.fetch("GTFS_SOURCE_URL", "OOPS, please set the GTFS_SOURCE_URL.")
    @active_schedule = Schedule.active_one

    #puts current_developer.class

    Analytics.track(
      user_id: "todo",
      event: "Homepage visit",
      properties: {
        rails_env: Rails.env
        request_id: request.request_id || request.uuid,
        remote_ip: request.remote_ip,
        user_agent: request.env["HTTP_USER_AGENT"],
        # cookie: request.env["HTTP_COOKIE"],
      }
    )
  end

end
