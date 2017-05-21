class Api::V0::ApiController < ApplicationController

  def index
    endpoint_params = params.permit(:hello).to_h
    endpoint_params[:hello] = "World" if endpoint_params[:hello].blank?

    initialize_response({:endpoint_params => endpoint_params, :resource => "Index"})
    @response[:results] = {:message => "Hello #{endpoint_params[:hello]}"}

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end

  def stations
    endpoint_params = params.permit(:geo).to_h
    endpoint_params[:geo] = "CT" if endpoint_params[:geo].blank?

    initialize_response({:endpoint_params => endpoint_params, :resource => "Stations"})
    @response[:results] = all_stations

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end

  def trains
    endpoint_params = params.permit(:origin, :destination, :date).to_h
    endpoint_params[:origin] = "BRN" if endpoint_params[:origin].blank?
    endpoint_params[:destination] = "NHV" if endpoint_params[:destination].blank?
    endpoint_params[:date] = Date.today.to_s if endpoint_params[:date].blank?

    initialize_response({:endpoint_params => endpoint_params, :resource => "Trains"})
    @response[:results] = [
      {:id => 1111, :origin_departure => Time.zone.now - 90.minutes, :destination_arrival => Time.zone.now - 75.minutes},
      {:id => 3333, :origin_departure => Time.zone.now - 5.minutes, :destination_arrival => Time.zone.now + 10.minutes},
      {:id => 5555, :origin_departure => Time.zone.now, :destination_arrival => Time.zone.now + 15.minutes},
      {:id => 7777, :origin_departure => Time.zone.now + 30.seconds, :destination_arrival => Time.zone.now + 16.minutes},
      {:id => 9999, :origin_departure => Time.zone.now + 90.seconds, :destination_arrival => Time.zone.now + 17.minutes},
      {:id => 2121, :origin_departure => Time.zone.now + 3.minutes, :destination_arrival => Time.zone.now + 18.minutes},
      {:id => 5656, :origin_departure => Time.zone.now + 25.minutes, :destination_arrival => Time.zone.now + 40.minutes},
      {:id => 9797, :origin_departure => Time.zone.now + 45.minutes, :destination_arrival => Time.zone.now + 65.minutes},
      {:id => 2424, :origin_departure => Time.zone.now + 100.minutes, :destination_arrival => Time.zone.now + 115.minutes},
    ]

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end

  private

  def initialize_response(endpoint_params:, resource:)
    @response = {
      :endpoint => request.path,
      :resource => resource,
      :params => endpoint_params,
      :received_at => Time.zone.now,
      :errors => [],
      :results => []
    }
  end

  def all_stations
    [
      {
        "id":1612,
        "abbrev":"NHV",
        "name":"New Haven Union Station",
        "latitude":"41.297719",
        "longitude":"-72.926731",
        "url":"http://www.shorelineeast.com/service_info/stations/nh_u.php",
      },
      {
        "id":1622,
        "abbrev":"ST",
        "name":"New Haven State Street Station",
        "latitude":"41.304985",
        "longitude":"-72.921764",
        "url":"http://www.shorelineeast.com/service_info/stations/nh_s.php"
      },
      {
        "id":1632,
        "abbrev":"BRN",
        "name":"Branford",
        "latitude":"41.274628",
        "longitude":"-72.817246",
        "url":"http://www.shorelineeast.com/service_info/stations/branford.php"
      },
      {
        "id":1642,
        "abbrev":"GUIL",
        "name":"Guilford",
        "latitude":"41.275819",
        "longitude":"-72.673643",
        "url":"http://www.shorelineeast.com/service_info/stations/guilford.php"
      },
      {
        "id":1652,
        "abbrev":"MAD",
        "name":"Madison",
        "latitude":"41.283668",
        "longitude":"-72.599539",
        "url":"http://www.shorelineeast.com/service_info/stations/madison.php"
      },
      {
        "id":1662,
        "abbrev":"CLIN",
        "name":"Clinton",
        "latitude":"41.279486",
        "longitude":"-72.5283",
        "url":"http://www.shorelineeast.com/service_info/stations/clinton.php"
      },
      {
        "id":1672,
        "abbrev":"WES",
        "name":"Westbrook",
        "latitude":"41.288763",
        "longitude":"-72.448402",
        "url":"http://www.shorelineeast.com/service_info/stations/westbrook.php",
      },
      {
        "id":1682,
        "abbrev":"OSB",
        "name":"Old Saybrook",
        "latitude":"41.300391",
        "longitude":"-72.376825",
        "url":"http://www.shorelineeast.com/service_info/stations/old_saybrook.php",
      },
      {
        "id":1692,
        "abbrev":"NLC",
        "name":"New London",
        "latitude":"41.354158",
        "longitude":"-72.093076",
        "url":"http://www.shorelineeast.com/service_info/stations/new_london.php"
      },


      {
        "id":1702,
        "abbrev":"GCS",
        "name":"Grand Central Station",
        "latitude":"40.753165",
        "longitude":"-73.977379",
        "url":"http://as0.mta.info/mnr/stations/station_detail.cfm",
      },
      {
        "id":1712,
        "abbrev":"GW",
        "name":"Greenwich",
        "latitude":"41.021705",
        "longitude":"-73.624597",
        "url":"http://as0.mta.info/mnr/stations/station_detail.cfm"
      },
      {
        "id":1722,
        "abbrev":"STM",
        "name":"Stamford",
        "latitude":"41.046654",
        "longitude":"-73.542845",
        "url":"http://as0.mta.info/mnr/stations/station_detail.cfm?key=226"
      },
      {
        "id":1732,
        "abbrev":"SN",
        "name":"South Norwalk",
        "latitude":"41.095529",
        "longitude":"-73.421803",
        "url":"http://as0.mta.info/mnr/stations/station_detail.cfm"
      },
      {
        "id":1742,
        "abbrev":"BRP",
        "name":"Bridgeport",
        "latitude":"41.178702",
        "longitude":"-73.187077",
        "url":"http://as0.mta.info/mnr/stations/station_detail.cfm?key=246"
      },
      {
        "id":1752,
        "abbrev":"STR",
        "name":"Stratford",
        "latitude":"41.194286",
        "longitude":"-73.131566",
        "url":"http://as0.mta.info/mnr/stations/station_detail.cfm?key=248"
      },
      {
        "id":1762,
        "abbrev":"MIL",
        "name":"Milford",
        "latitude":"41.22323",
        "longitude":"-73.057666",
        "url":"http://as0.mta.info/mnr/stations/station_detail.cfm?key=250"
      },
      {
        "id":1772,
        "abbrev":"WH",
        "name":"West Haven",
        "latitude":"41.271408",
        "longitude":"-72.964722",
        "url":"http://as0.mta.info/mnr/stations/station_detail.cfm?key=251"
      }
    ]
  end

end
