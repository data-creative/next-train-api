module ApiResponseHelpers
  def parsed_response
    JSON.parse(response.body).deep_symbolize_keys
  end

  def expect_results
    expect(parsed_response[:results]).to_not be_blank
  end

  def expect_no_errors
    expect(parsed_response[:errors]).to be_blank
  end

  def expect_successful_response
    expect_results
    expect_no_errors
  end
end

RSpec.configure do |config|
  config.include ApiResponseHelpers
end
