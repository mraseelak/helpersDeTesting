# frozen_string_literal: true

module TestHelpers
  module API
    class Error < StandardError; end

    class NoURLProvided < StandardError; end

    class NoTokenProvided < StandardError; end

    class RequestIncomplete < StandardError; end
  end
end
