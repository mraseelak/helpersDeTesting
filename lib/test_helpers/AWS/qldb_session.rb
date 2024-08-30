# frozen_string_literal: true

require 'aws-sdk-qldbsession'

require_relative 'aws_base'
require_relative 'aws_errors'

# This module deals with the QLDB Session module of AWS.

module TestHelpers
  module AWS
    class QLDBSession < TestHelpers::AWS::Base
      attr_accessor :client, :ledger, :statement

      def initialize(options)
        raise TestHelpers::AWS::NoRegionProvided, 'No Region Provided' if options[:region].nil?
        raise 'ledger not provided' if options[:ledger].nil?

        # raise 'statement not provided' if options(:statement).nil?
        # raise 'table not provided' if options(:statement).nil?

        super options
        @client = Aws::QLDBSession::Client.new(@aws_options)
        @ledger = options[:ledger]
      end

      def execute_statement(statement)
        session_token = start_session

        @client.send_command(
          session_token: session_token,
          execute_statement: {
            transaction_id: start_transaction(session_token),
            statement: statement
          }
        )
        # puts "RESULT OF #{statement}"
        # puts resp.inspect
      end

      private

      def start_session
        resp = @client.send_command(start_session: { ledger_name: @ledger })
        resp.start_session.session_token
      end

      def start_transaction(session_id)
        resp = @client.send_command(
          session_token: session_id,
          start_transaction: {}
        )
        puts 'START_TRANSACTION'
        resp.start_transaction.transaction_id
      end
    end
  end
end
