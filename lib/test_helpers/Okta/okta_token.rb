# frozen_string_literal: true

require 'base64'
require 'uri'
require 'ostruct'
require 'httparty'

## This module is to generate an okta token either the client sign in or the user sign in.
module TestHelpers
  # module Okta Called by using TestHelpers::Okta
  module Okta
    module_function

    class << self
      attr_accessor :issuer
      attr_reader :response
      attr_writer :client_id, :client_secret
    end

    def configure!(issuer: nil)
      @issuer = issuer
      Client.base_uri @issuer
    end

    ##
    # Used to retrieve the access_token and id_token for user under Okta
    # @param username [String]
    # @param password [String]
    # @param scope [String] Default value is 'openid'
    # @param grant_type [String] Default value is 'password'
    # @param client_id
    # @param client_secret
    # @return Response from Okta. Raises an error if the response from Okta is not 200.
    def user_sign_in(username:, password:, client_id:, client_secret:, scope: 'openid', grant_type: 'password')
      @scope = scope
      @grant_type = grant_type
      @client_id = client_id
      @client_secret = client_secret
      options = {
        headers: headers,
        query: {
          username: username,
          password: password,
          scope: @scope,
          grant_type: @grant_type
        }
      }

      @response = Client.post('/v1/token', options)
    end

    ##
    # Used to retrieve access token for clients
    # @param scope [String] Default value is 'openid'

    # @param client_id
    # @param client_secret
    # @return Response from Okta. Raises an error if the response from Okta is not 200.
    def client_sign_in(client_id:, client_secret:, scope: nil)
      @scope = scope
      @grant_type = 'client_credentials'
      @client_id = client_id
      @client_secret = client_secret
      query = { grant_type: @grant_type, scope: scope }.compact
      options = {
        headers: headers,
        query: query
      }

      @response = Client.post('/v1/token', options)
    end

    def id_token
      @response.parsed_response['id_token']
    end

    def access_token
      @response.parsed_response['access_token']
    end

    def headers
      {
        'Authorization' => "Basic: #{Base64.strict_encode64("#{@client_id}:#{@client_secret}")}",
        'Accept' => 'application/json',
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    end

    ## This is the HTTPARTY client used by others in the module to send requests
    class Client
      include HTTParty
      raise_on [404, 500, 400]
    end
  end
end
