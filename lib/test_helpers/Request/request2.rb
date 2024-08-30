# frozen_string_literal: true

require 'byebug'
require 'httparty'
# require 'net/http'
require_relative '../Request/request_errors'
require_relative '../Request/response'

## This module of the test helpers is used to create a request and return a standardized response for the API call that
# can be consumed by the tests
module TestHelpers
  module API
    ## This is the request class. This class uses the HttpClient class to make the actual request
    class Request2
      def self.get(**args)
        new(**args).get
      end

      def initialize(url:, id_token: nil, auth0_on: true, headers: {}, payload: nil)
        raise TestHelpers::API::NoURLProvided unless url
        raise TestHelpers::API::NoTokenProvided if auth0_on && !id_token

        @url      = url
        @id_token = id_token
        @headers  = headers
        @headers  = @headers.merge('Authorization' => "Bearer #{id_token}") if auth0_on
        @payload  = payload
        @timeout  = timeout
        @response = TestHelpers::API::Response.new
      end

      def get
        @resp = HttpClient.get(@url, headers: @headers)
      rescue StandardError => e
        puts e.backtrace
      end

      private

      def check_payload_type
        raise TestHelpers::API::RequestIncomplete if @payload.nil?

        raise TestHelpers::API::RequestIncomplete, 'Payload should a Hash or an Array' unless @payload.is_a?(Hash) || @payload.is_a?(Array)
      end

      def process_response!
        @response.status    = @resp.code.to_s =~ /20(\d)/ ? 'Success' : 'Failure'
        @response.http_code = @resp.code.to_s
        @response.message   = JSON.parse(@resp.body)
        @response
      rescue JSON::ParserError
        puts 'Response is not in JSON Format. Saving message as string'
        @response.message = @resp.body
        @response
      end

      def setup_error(error)
        puts error
        @response.status = 'Failure'
        @response.backtrace = error.backtrace
        if error.respond_to? :http_code
          @response.http_code = error.http_code.to_s
          @response.message   = begin
            JSON.parse(error.response.body)
          rescue StandardError
            error.response.to_s
          end
        else
          @response.http_code = '500'
          @response.message   = error.to_s
        end
        @response
      end
    end

    class HttpClient
      include HTTParty

      raise_on [400, 404, 500, 403, 401]
    end
  end
end
