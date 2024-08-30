# frozen_string_literal: true

require 'rest-client'
require 'net/http'
require_relative '../Request/request_errors'
require_relative '../Request/response'
module TestHelpers
  module API
    #####
    # This Class is used to make requests to API. The response is an object
    # of the TestHelpers::API::Response class and is intended to
    # standardize the response for testing.
    # Mandatory parameters:
    # url
    # Optional parameters:
    # id_token: The string token received from Auth0 used for authorization
    # headers: hash with request headers. id_token is needed if auth0_on is true
    class Request
      attr_accessor

      attr_reader :url, :response, :id_token, :headers, :payload

      def self.get(**args)
        new(**args).get
      end

      def self.post(**args)
        new(**args).post
      end

      def self.put(**args)
        new(**args).put
      end

      def self.patch(**args)
        new(**args).patch
      end

      def self.delete(**args)
        new(**args).delete
      end

      def initialize(url:, id_token: nil, auth0_on: true, headers: {}, payload: nil, timeout: 120)
        raise TestHelpers::API::NoURLProvided unless url

        raise TestHelpers::API::NoTokenProvided if auth0_on && !id_token

        @response = TestHelpers::API::Response.new
        @url      = url
        @id_token = id_token
        @headers  = headers
        @headers  = @headers.merge('Authorization' => "Bearer #{id_token}") if auth0_on
        @payload  = payload
        @timeout  = timeout
        @response.url = @url
      end

      def get
        @response.method_call = 'get'
        @resp = RestClient::Request.execute(
          url: @url,
          method: :get,
          verify_ssl: false,
          headers: @headers
        )

        process_response!
      rescue StandardError => e
        setup_error(e)
      end

      def post
        @response.method_call = 'post'
        options = {
          url: @url,
          method: :post,
          verify_ssl: false,
          payload: @payload,
          headers: @headers,
          timeout: @timeout
        }.compact

        @resp = RestClient::Request.execute(options)
        process_response!
      rescue StandardError => e
        setup_error(e)
      end

      def put
        @response.method_call = 'put'
        options = {
          url: @url,
          method: :put,
          verify_ssl: false,
          payload: @payload,
          headers: @headers,
          timeout: @timeout
        }.compact

        @resp = RestClient::Request.execute(options)
        process_response!
      rescue StandardError => e
        setup_error e
      end

      def patch
        @response.method_call = 'patch'
        options = {
          url: @url,
          method: :patch,
          verify_ssl: false,
          payload: @payload,
          headers: @headers,
          timeout: @timeout
        }.compact

        @resp = RestClient::Request.execute(options)

        process_response!
      rescue StandardError => e
        setup_error e
      end

      def delete
        @response.method_call = 'delete'
        options = {
          url: @url,
          method: :delete,
          verify_ssl: false,
          headers: @headers
        }
        options[:payload] = @payload.to_json if @payload

        @resp = RestClient::Request.execute(options)
        process_response!
      rescue StandardError => e
        setup_error(e)
      end

      private

      def check_payload_type
        raise TestHelpers::API::RequestIncomplete if @payload.nil?

        raise TestHelpers::API::RequestIncomplete, 'Payload should a Hash or an Array' unless @payload.is_a?(Hash) || @payload.is_a?(Array)
      end

      def process_response!
        @response.status    = @resp.code.to_s =~ /20(\d)/ ? 'Success' : 'Failure'
        @response.headers   = @resp.headers
        @response.http_code = @resp.code.to_s
        @response.message   = @resp.body.is_a?(Hash) ? @resp.body.transform_keys(&:to_s) : JSON.parse(@resp.body, symbolize_keys: false)
        @response
      rescue JSON::ParserError
        @response.message = @resp.body
        @response
      end

      def setup_error(error)
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
  end
end
