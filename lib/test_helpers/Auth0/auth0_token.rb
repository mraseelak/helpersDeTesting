# frozen_string_literal: true

require_relative '../Auth0/auth0_errors'
require 'json'
require 'rest-client'
require 'ostruct'

module TestHelpers
  # This class is to generate the Auth0Token for use with other requests.
  class Auth0Token
    attr_accessor :username, :password, :response
    attr_reader :client_id, :grant_type, :connection, :scope, :url

    def initialize(options = {})
      @grant_type = options[:grant_type]
      @client_id  = options[:client_id]
      @connection = options[:connection]
      @scope      = options[:scope]
      @url        = options[:url]
      @username   = options[:username]
      @password   = options[:password]
      raise TestHelpers::Auth0::ClientIDMissing, 'Client Id Missing.' unless @client_id
      raise TestHelpers::Auth0::ConnectionMissing, 'Connection not provided.' unless @connection
      raise TestHelpers::Auth0::GrantTypeMissing, 'Grant type not provided' unless @grant_type
      raise TestHelpers::Auth0::ScopeMissing, 'Scope Not provided' unless @scope
      raise TestHelpers::Auth0::Auth0URL, 'URL to connect to Auth0 not provided' unless @url
    end

    def user_set(username)
      @username = username
      'User Name Set'
    end

    def password_set(password)
      @password = password
      'Password Set'
    end

    def build_user(username, password)
      raise ArgumentError, 'Username not provided' if username.nil?
      raise ArgumentError, 'Password not provided' if password.nil?

      user_set(username)
      password_set(password)
      'Info Set'
    end

    def get_token(username = nil, password = nil)
      build_user(username, password) if @username.nil? || @password.nil?

      begin
        response = RestClient::Request.execute(method: :post,
                                               url: @url,
                                               payload: payload,
                                               headers: {})

        @response = OpenStruct.new(JSON.parse(response.body))
      rescue StandardError
        raise TestHelpers::Auth0::TokenGenerationError
      end
    end

    def payload
      {
        client_id: @client_id,
        username: @username,
        password: @password,
        grant_type: @grant_type,
        scope: @scope,
        connection: @connection
      }
    end

    def id_token
      raise TestHelpers::Auth0::TokenGenerationError if @response.id_token.nil?

      @response.id_token
    end

    def access_token
      raise TestHelpers::Auth0::TokenGenerationError if @response.access_token.nil?

      @response.access_token
    end

    def token_type
      raise TestHelpers::Auth0::TokenGenerationError if @response.token_type.nil?

      @response.token_type
    end
  end
end
