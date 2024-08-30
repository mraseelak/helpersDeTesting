# frozen_string_literal: true

require 'aws-sdk-lambda'
require_relative 'request_errors'
require_relative 'response'
require_relative '../AWS/aws_base'
require_relative '../AWS/aws_errors'
require_relative '../support'

module TestHelpers
  module API
    # This is the class that the user will interface with.
    # Although there is no default client the preferred cleitn is pmacc-common-bdd-proxy-client
    # it can be set using the function_name
    class Proxy < TestHelpers::AWS::Base
      class << self
        attr_accessor :function_name
        attr_reader :response

        def configure!(options)
          raise TestHelpers::AWS::NoFunctionNameProvided if options[:function_name].nil?

          options[:region] ||= 'us-east-1'
          base = TestHelpers::AWS::Base.new(options)
          @proxy = Aws::Lambda::Client.new(base.aws_options)
          @function_name = options[:function_name]
          @response = TestHelpers::API::Response.new
        end

        def get(url: nil, headers: {})
          @response.url = url
          @response.method_call = 'get'
          @request = { method: :get, url: url, headers: headers }
          send_request
        end

        # The metaprorgamming code below this comment section is to replace all the code that is seen here.
        # Please follow the call to the various methods as shown below in the code.
        # I am leaving this code commented out here so that I can see what is going on 6 months later.
        # Though both of them have been tested many times, I am leaving the hard implementation if something does go wrong.
        # So there! Long post about this that no one will read :(. But metaprogramming in Ruby is awesome
        #
        # def post(url: nil, headers: nil, payload_string: nil)
        # end
        #
        # def put(url: nil, headers: nil, payload_string: nil)
        # end
        #
        # def patch(url: nil, headers: nil, payload_string: nil)
        #   @response.url = url
        #   @request = { method: :patch, url: url, headers: headers, payload: payload_string }.compact
        #   send_request
        # end
        #
        # def delete(url: nil, headers: nil, payload_string: nil)
        # end
        %I[post put delete patch].each do |method|
          define_method method do |options|
            raise 'URL not provided' if options[:url].nil?

            @response.url = options[:url]
            @response.method_call = method.to_s
            @request = { method: method, url: options[:url], headers: options[:headers], payload: options[:payload_string] }.compact
            send_request
          end
        end

        private

        def send_request
          @resp = @proxy.invoke(function_name: @function_name, payload: @request.to_json)
          process_response
        rescue RuntimeError => e
          puts e.class
          puts e.message
          process_error e
        end

        def process_response
          response = @resp.to_h[:payload].read
          resp_hash = JSON.parse(response) if Support.valid_json? response
          message = if Support.valid_json? resp_hash['response']
                      JSON.parse(resp_hash['response'])
                    else
                      response
                    end

          @response.status = resp_hash['http_code'].to_s.match?(/20(\d)/) ? 'Success' : 'Failure'
          @response.http_code = resp_hash['http_code'].to_s
          @response.message = message
          @response
        rescue RuntimeError => e
          puts 'This is the value being processed before failure.'
          puts @resp
          raise e
        end

        def process_error(error)
          @response.status = 'Failure'
          @response.backtrace = error.backtrace
          if !@resp['http_code'].nil?
            @response.http_code = @resp['http_code'].to_s
            @response.message   = begin
              JSON.parse(error.response.body)
            rescue StandardError
              error.to_s
            end
          else
            @response.http_code = '500'
            @response.message   = error.to_s
          end
        end
      end
    end
  end
end
