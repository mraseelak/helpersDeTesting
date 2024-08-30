# frozen_string_literal: true

module TestHelpers
  module API
    # Response Object created for all requests.
    class Response
      attr_accessor :status, :http_code, :message, :backtrace, :headers, :url, :method_call

      def initialize
        @status = nil
        @http_code = nil
        @url = nil
        @method_call = nil
        @headers = nil
        @message = nil
        @backtrace = nil
      end

      def to_s
        <<~MESSAGE
          status: #{@status},#{' '}
          http_code: #{@http_code},#{' '}
          message: #{@message},#{' '}
          url: #{@url},#{' '}
          method: #{@method_call},#{' '}
          backtrace: #{@backtrace}
        MESSAGE
      end
    end
  end
end
