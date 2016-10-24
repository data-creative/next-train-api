class Api::V1::ApiController < ApplicationController

  def index
    @response = {
      :url => request.url,
      :params => params.reject{|k,v| ["controller","format","action"].include?(k) },
      :received_at => Time.zone.now,
      :errors => [],
      :results => {:message => "Hello World"}
    }

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end

  def stations
    @response = {
      :url => request.url,
      :params => params.reject{|k,v| ["controller","format","action"].include?(k) },
      :received_at => Time.zone.now,
      :errors => [],
      :results => []
    }

    stations = [
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
      }
    ]

    @response[:results] = stations

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end

  def trains
    @response = {
      :url => request.url,
      :params => params.reject{|k,v| ["controller","format","action"].include?(k) },
      :received_at => Time.zone.now,
      :errors => [],
      :results => [
        {:origin_departure => "10:00am", :destination_arrival => "10:15am"},
        {:origin_departure => "10:45am", :destination_arrival => "11:01am"},
        {:origin_departure => "5:05pm", :destination_arrival => "5:21pm"},
        {:origin_departure => "6:25pm", :destination_arrival => "6:41pm"}
      ]
    }

    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end

end
