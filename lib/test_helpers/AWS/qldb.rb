# frozen_string_literal: true

require 'aws-sdk-qldb'

require_relative 'aws_base'
require_relative 'aws_errors'

# This module deals with the QLDB module of AWS.
module TestHelpers
  module AWS
    # This class stores all the commonly used methods of QLDB
    class QLDB < TestHelpers::AWS::Base
      LEDGER_CREATION_POLL_PERIOD_SEC = 10
      LEDGER_DELETION_POLL_PERIOD_SEC = 20
      ACTIVE_STATE = 'ACTIVE'

      attr_accessor :client, :product, :ledger, :table, :index

      def initialize(options)
        raise TestHelpers::AWS::NoRegionProvided, 'No Region Provided' if options[:region].nil?

        super options

        @client = Aws::QLDB::Client.new(@aws_options)
        @session_client = Aws::QLDBSession::Client.new(@aws_options)
        @product = options[:product]
      end

      def describe_ledger(ledger)
        TestHelpers::Logger.log("Describing Ledger #{ledger}")
        @client.describe_ledger(name: ledger)
      end

      # Creates a ledger with the name provided
      # @param ledger: STRING, name of the ledger to be created
      def create_ledger(ledger)
        TestHelpers::Logger.log("Creating Ledger: #{ledger}")
        response = @client.create_ledger(
          name: ledger, # required
          tags: {
            'ENVIRONMENT' => 'dev',  # Since Leidos is using the tagging policy on testing,
            'PRODUCT' => @product    # we are adding the following tags
          },
          permissions_mode: 'ALLOW_ALL',
          deletion_protection: false
        )
        TestHelpers::Logger.log("Success: Ledger state is #{response.state}")
        response
      end

      # Waits for the creation of the ledger by making sure that the ledger description is active
      # @param ledger: STRING, name of the ledger to being created
      def wait_for_active_ledger(ledger)
        TestHelpers::Logger.log('Waiting for ledger to become active...')
        loop do
          result = describe_ledger(ledger)
          if result.state == ACTIVE_STATE
            TestHelpers::Logger.log("Success. Ledger #{ledger} is active and ready to use.")
            return result
          else
            TestHelpers::Logger.log('The ledger is still being created. Please wait...')
            sleep LEDGER_CREATION_POLL_PERIOD_SEC
          end
        end
      end

      # Deletes a ledger with the name provided
      # @param ledger: STRING, name of the ledger to be deleted
      def delete_ledger(ledger)
        TestHelpers::Logger.log("Attempting to delete the ledger #{ledger}")
        result = @client.delete_ledger(name: ledger)
        TestHelpers::Logger.log('Success')
        result
      rescue RuntimeError => e
        TestHelpers::Logger.log(e.backtrace, :error)
      end

      # Polls for the presence of the ledger. When there is no ledger it raises a resource not found exception
      # @param ledger: STRING, name of the ledger being deleted
      def wait_for_ledger_deletion(ledger)
        TestHelpers::Logger.log('Waiting for the ledger to be deleted...')
        while TRUE
          describe_ledger(ledger)
          TestHelpers::Logger.Log('The ledger is still being deleted')
          sleep LEDGER_DELETION_POLL_PERIOD_SEC
        end
      rescue Aws::QLDB::Errors::ResourceNotFoundException > err
        TestHelpers::Logger.log('Success... The Ledger has been deleted')
      end

      # Sets the delete protection flag. This has to be set to false in order for the delete to happen.
      # @param ledger: STRING, name of the ledger
      # @param delete_flag: BOOLEAN, true to protect and false to remove protection
      def set_delete_protection(ledger, delete_flag)
        TestHelpers::Logger("Setting the delete protection for '#{ledger}' to '#{delete_flag}'")
        @client.update_ledger(
          name: ledger,
          deletion_protection: delete_flag
        )
      rescue RuntimeError => e
        TestHelpers::Logger.log(e, :error)
      end
    end
  end
end
