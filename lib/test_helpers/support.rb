# frozen_string_literal: true

# Catch all class that are used as utilities for the rest of them
class Support
  class << self
    def valid_json?(string)
      !!JSON.parse(string)
    rescue JSON::ParserError
      false
    end
  end
end
