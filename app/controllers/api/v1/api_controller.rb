class Api::V1::ApiController < Api::ApiController

  def stations
    initialize_response
    #validate_api_key
    @response[:results] = stations #if api_key_valid?
    return_pretty_json_response
  end

  #private

  def initialize_response
    @reponse = {
      :request => {
        :url => request.url,
        :params => params.reject{|k,v| ["controller","format","action"].include?(k) },
        :received_at => Time.zone.now
      },
      :errors => [],
      :results => []
    }
  end

  #def validate_api_key
  #  if !params["api_key"]
  #    @response[:errors] << MissingApiKeyError.new.message
  #  else
  #    @api_key = ApiKey.find_by_token(params["api_key"])
  #    @response[:errors] << UnrecognizedApiKeyError.new(params["api_key"]).message if !@api_key
  #  end
  #end

  #def api_key_valid?
  #  @api_key && @api_key.is_a?(ApiKey) && @api_key.unrevoked?
  #end

  def return_pretty_json_response
    respond_to do |format|
      format.json { render json: JSON.pretty_generate(@response) }
    end
  end

  def stations
    [
      {"id":1622, "abbrev":"ST", "name":"New Haven State Street Station", "latitude":"41.304985", "longitude":"-72.921764", "url":"http://www.shorelineeast.com/service_info/stations/nh_s.php"},
      {"id":1632, "abbrev":"BRN", "name":"Branford", "latitude":"41.274628", "longitude":"-72.817246", "url":"http://www.shorelineeast.com/service_info/stations/branford.php"},
      {"id":1642, "abbrev":"GUIL", "name":"Guilford", "latitude":"41.275819", "longitude":"-72.673643", "url":"http://www.shorelineeast.com/service_info/stations/guilford.php"}
    ]
  end # todo: get from database
end
