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

    q = @response[:query]

    if q[:origin].blank?
      @response[:errors] << "Please specify an origin station abbreviation (e.g. 'BRN')."
    elsif !station_abbreviation_valid?(q[:origin])
      @response[:errors] << "Invalid origin station abbreviation"
    end

    if q[:destination].blank?
      @response[:errors] << "Please specify a destination station abbreviation (e.g. 'NHV')."
    elsif !station_abbreviation_valid?(q[:destination])
      @response[:errors] << "Invalid destination station abbreviation"
    end

    if q[:date].blank?
      @response[:errors] << "Please specify a departure date (e.g. '#{Date.today.to_s}')."
    elsif !date_valid?(q[:date])
      @response[:errors] << "Invalid departure date"
    end

    #
    # Populate results
    #

    @response[:results] = if @response[:errors].empty?
      Api::V1::TrainsResponse.new(q).results
    end

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end

  private

  def date_valid?(date_string)
    y, m, d = date_string.strip.split("-")
    Date.valid_date?(y.to_i, m.to_i, d.to_i)
  end

  def station_abbreviation_valid?(abbrev)
    station_abbrevs.include?(abbrev)
  end

  def station_abbrevs
    ["NHV","ST","BRN","GUIL","MAD","CLIN","WES","OSB","NLC"] #TODO: if possible, populate dynamically without calling the database
  end
end
