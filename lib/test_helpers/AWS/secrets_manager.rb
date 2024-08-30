# frozen_string_literal: true

require 'base64'
require 'aws-sdk-secretsmanager'
require_relative 'aws_errors'
require_relative 'aws_base'
## This code is provided by amazon aws service.
#
module TestHelpers
  module AWS
    class SecretValueRequestFailed < RuntimeError; end

    ## This class interacts with the AWS Secrets Manager. The class requires
    # the secret_id being used to store the secrets.
    class SecretsManager < TestHelpers::AWS::Base
      attr_reader :secret
      attr_writer :secret_id, :secret_manager

      def initialize(options)
        raise TestHelpers::AWS::SecretNameNotProvided, 'Secret Name not provided' if options[:secret_id].nil?
        raise TestHelpers::AWS::NoRegionProvided, 'No Aws Regions Provided' if options[:region].nil?

        super options

        @secret_id = options[:secret_id]
        @secret_manager = Aws::SecretsManager::Client.new(@aws_options)
      end

      def get_value(value)
        get_secret
        @secret[value]
      end

      def get_all
        get_secret
        @secret.to_json
      end

      private

      def get_secret
        # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
        # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        # We rethrow the exception by default.

        get_secret_value_response = @secret_manager.get_secret_value(secret_id: @secret_id)
      rescue Aws::SecretsManager::Errors::DecryptionFailure => e
        puts e.backtrace
        raise TestHelpers::AWS::SecretValueRequestFailed
      rescue Aws::SecretsManager::Errors::InternalServiceError => e
        puts e.backtrace
        raise TestHelpers::AWS::SecretValueRequestFailed
      rescue Aws::SecretsManager::Errors::InvalidParameterException => e
        puts e.backtrace
        raise TestHelpers::AWS::SecretValueRequestFailed
      rescue Aws::SecretsManager::Errors::InvalidRequestException => e
        puts e.backtrace
        raise TestHelpers::AWS::SecretValueRequestFailed
      rescue Aws::SecretsManager::Errors::ResourceNotFoundException => e
        puts e.backtrace
        raise TestHelpers::AWS::SecretValueRequestFailed
      else
        # This block is run if there were no exceptions.

        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        response = get_secret_value_response.secret_string || Base64.decode64(get_secret_value_response.secret_binary)
        @secret = JSON.parse(response)
      end
    end
  end
end
