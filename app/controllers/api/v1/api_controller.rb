require "./app/models/api/v1/responses/trains_response"

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
    options = params.permit(:origin, :destination, :date).to_h

    @response ||= Api::V1::TrainsResponse.new(options)

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response.to_h) }
    end
  end
end
