require 'active_support/concern'

module DateFormatter
  extend ActiveSupport::Concern

  class_methods do

    # @param [String] str A date-string in YYYY-MM-DD format.
    def day_of_week(str)
      Date.parse(str).strftime("%A").downcase #> "wednesday"
    end

  end
end
