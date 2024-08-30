# frozen_string_literal: true

module TestHelpers
  ## Get the version of the application
  module VERSION
    MAJOR = 1
    MINOR = 2
    PATCH = 25
    STRING = [MAJOR, MINOR, PATCH].compact.join('.')
    def self.version
      STRING
    end
  end
end
