class Api::ApiController < ApplicationController

  class ApiError < ArgumentError
    def error_class_name
      self.class.name.gsub("Api::ApiController::","")
    end
  end

  class ApiKeyError < ApiError ; end

  class MissingApiKeyError < ApiKeyError
    def initialize
      super(error_class_name)
    end
  end

  class UnrecognizedApiKeyError < ApiKeyError
    #
    # @param [String] token The unrecognized API Key token.
    def initialize(token)
      super("#{error_class_name} -- '#{token}'")
    end
  end
end
