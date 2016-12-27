class Api::V1::ApiController < ApplicationController

  # Trains Endpoint
  #
  # Returns an array of arrival and departure times matching a given train schedule query (origin station, destination station, and departure date).
  #
  # @param [String] origin The origin train station abbreviation (e.g. 'BRN').
  # @param [String] destination The destination train station abbreviation (e.g. 'NHV').
  # @param [String] date The date of departure in YYYY-MM-DD format (e.g. '2016-12-28').
  #
  # @example GET /api/v1/trains.json?origin=BRN&destination=NHV
  # @example GET /api/v1/trains.json?origin=BRN&destination=NHV&date=2016-12-28
  def trains
    query = params.permit(:origin, :destination, :date).to_h

    # Assemble initial response

    @response = {
      :endpoint => request.path,
      :response_type => "Trains",
      :query => query,
      :received_at => Time.zone.now,
      :errors => [],
      :results => []
    }

    # Parse request parameters

    @response[:errors] << "Please specify an origin station abbreviation (e.g. 'BRN')." if query[:origin].blank?
    @response[:errors] << "Please specify a destination station abbreviation (e.g. 'NHV')." if query[:destination].blank?
    @response[:errors] << "Please specify a departure date (e.g. '#{Date.today.to_s}')." if query[:date].blank?

    # Populate results

    #TODO

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end

end
