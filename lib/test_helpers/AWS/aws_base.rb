# frozen_string_literal: true

require_relative 'aws_errors'
module TestHelpers
  module AWS
    # This is the Base class for all things AWS.
    class Base
      attr_reader :access_key_id, :secret_access_key, :aws_options

      def initialize(options)
        raise TestHelpers::AWS::NoAccessKeyProvided, 'No Aws Access Key Provided' if options[:access_key_id].nil?
        raise TestHelpers::AWS::NoSecretAccessKeyProvided, 'No Aws Secret Access Key Provided' if options[:secret_access_key].nil?

        @region = options[:region]
        @endpoint = options[:endpoint]
        @access_key_id = options[:access_key_id]
        @secret_access_key = options[:secret_access_key]
        @session_token = options[:session_token]

        @aws_options = {
          endpoint: @endpoint,
          region: @region,
          access_key_id: @access_key_id,
          secret_access_key: @secret_access_key,
          session_token: @session_token
        }.compact
      end
    end
  end
end
