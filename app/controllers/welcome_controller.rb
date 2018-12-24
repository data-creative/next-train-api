class WelcomeController < ApplicationController

  def index
    @active_schedule = Schedule.active_one
  end

end
