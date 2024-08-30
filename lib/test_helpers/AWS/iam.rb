# frozen_string_literal: true

require 'aws-sdk-iam'
require_relative 'aws_errors'
require_relative 'aws_base'
require 'date'

module TestHelpers
  module AWS
    # This class is used to collect information for S3 buckets and files provided.
    class IAM < TestHelpers::AWS::Base
      def initialize(options)
        raise TestHelpers::AWS::NoRegionProvided, 'No Aws Regions Provided' if options[:region].nil?

        super options
      end

      # create signing key
      def signing_key
        date = OpenSSL::HMAC.digest('sha256', "AWS4#{@secret_access_key}", Time.new.getutc.strftime('%Y%m%d').to_s)
        region = OpenSSL::HMAC.digest('sha256', date, @region)
        service = OpenSSL::HMAC.digest('sha256', region, @service_name)
        signing = OpenSSL::HMAC.digest('sha256', service, 'aws4_request')

        @signing_key = Digest.hexencode(signing)
      end

      # create canonical Request
      def canonical_request
        payload = "#{@method}\n"\
                  "#{@url}\n"\
                  "\n"\
                  "cache-control:\n"\
                  "content-type:application/x-www-form-urlencoded\n"\
                  "host:#{@host}\n"\
                  "x-amz-date:#{Time.new.getutc.strftime('%Y%m%dT%H%M%SZ')}\n"\
                  "x-amz-security-token:#{@session_token}\n"\
                  "\n"\
                  "cache-control;content-type;host;x-amz-date;x-amz-security-token\n"\
                  "#{Digest::SHA256.hexdigest('')}"

        Digest::SHA256.hexdigest(payload)
      end

      def prepare_header(method: 'GET', url: nil, host: 'uploaderapi.match-int.nci.nih.gov', service_name: 'execute-api')
        @method = method
        @url = url
        @host = host
        @service_name = service_name

        signing_key

        string_to_sign = "AWS4-HMAC-SHA256\n"\
        "#{Time.new.getutc.strftime('%Y%m%dT%H%M%SZ')}\n"\
        "#{Time.new.getutc.strftime('%Y%m%d')}/#{@region}/#{@service_name}/aws4_request\n"\
        "#{canonical_request}"

        # calculate signature
        signature = OpenSSL::HMAC.hexdigest('sha256', [@signing_key].pack('H*'), string_to_sign)
        credential = "#{@access_key_id}/#{Time.new.getutc.strftime('%Y%m%d')}/#{@region}/#{@service_name}/aws4_request,"\
        "SignedHeaders=cache-control;content-type;host;x-amz-date;x-amz-security-token,Signature=#{signature}"
        {
          content_type: 'application/x-www-form-urlencoded',
          host: @host,
          x_amz_security_token: @session_token,
          x_amz_date: Time.new.getutc.strftime('%Y%m%dT%H%M%SZ'),
          Authorization: "AWS4-HMAC-SHA256 Credential=#{credential}"
        }.compact
      end
    end
  end
end
