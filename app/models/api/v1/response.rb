class Api::V1::Response
  attr_reader :query, :received_at, :response_type, :errors, :results

  def initialize(options = {})
    @query = options
    @received_at = Time.zone.now
    @response_type = self.class.name
    @errors = []
    validate_query
    @results = generate_results
  end

  def to_h
    raise "#to_h should be implemented in the child class. it should return a hash. this is what will be passed to the view."
  end

private

  def validate_query
    raise "#validate_query should be implemented in the child class. it should parse the query params and add errors to the response as applicable."
  end

  def generate_results
    errors.empty? ? query_results : []
  end

  def query_results
    raise "#query_results should be implemented in the child class. it should return an array of resources matching the given criteria"
  end
end
