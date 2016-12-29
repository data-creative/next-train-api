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

    #
    # Assemble initial response
    #

    @response = {
      :endpoint => request.path,
      :response_type => "Trains",
      :query => params.permit(:origin, :destination, :date).to_h,
      :received_at => Time.zone.now,
      :errors => [],
      :results => []
    }

    #
    # Parse request parameters
    #

    if @response[:query][:origin].blank?
      @response[:errors] << "Please specify an origin station abbreviation (e.g. 'BRN')."
    elsif !station_abbreviation_valid?(@response[:query][:origin])
      @response[:errors] << "Invalid origin station abbreviation"
    end

    if @response[:query][:destination].blank?
      @response[:errors] << "Please specify a destination station abbreviation (e.g. 'NHV')."
    elsif !station_abbreviation_valid?(@response[:query][:destination])
      @response[:errors] << "Invalid destination station abbreviation"
    end

    if @response[:query][:date].blank?
      @response[:errors] << "Please specify a departure date (e.g. '#{Date.today.to_s}')."
    elsif !date_valid?(@response[:query][:date])
      @response[:errors] << "Invalid departure date"
    end

    # Populate results

    if @response[:errors].empty?
      @response[:results] = [
        {
          "id": 1111,
          "origin_departure": "2016-12-27 15:44:47 -0500",
          "destination_arrival": "2016-12-27 15:59:47 -0500"
        },
        {
          "id": 3333,
          "origin_departure": "2016-12-27 17:09:47 -0500",
          "destination_arrival": "2016-12-27 17:24:47 -0500"
        },
        {
          "id": 5555,
          "origin_departure": "2016-12-27 17:14:47 -0500",
          "destination_arrival": "2016-12-27 17:29:47 -0500"
        },
        {
          "id": 7777,
          "origin_departure": "2016-12-27 17:15:17 -0500",
          "destination_arrival": "2016-12-27 17:30:47 -0500"
        }
      ]# TODO: fetch results from database
    end

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end

  private

  def date_valid?(date_string)
    begin
      Date.parse(date_string)
      return true
    rescue ArgumentError
      return false
    end
  end

  def station_abbreviation_valid?(abbrev)
    station_abbrevs.include?(abbrev)
  end

  def station_abbrevs
    ["NHV","ST","BRN","GUIL","MAD","CLIN","WES","OSB","NLC"] #TODO: if possible, populate dynamically without calling the database
  end
end
