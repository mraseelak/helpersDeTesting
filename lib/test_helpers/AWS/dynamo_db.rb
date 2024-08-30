# frozen_string_literal: true

# Code taken from Damir Roso's implementation of dynamo_helpers
# project: https://github.com/damir/dynamodb_helpers

require 'aws-sdk-dynamodb'
require_relative 'aws_errors'
require_relative 'aws_base'
module TestHelpers
  module AWS
    # This class connects to the dynamodb and retrieves information from the db provided.
    class DynamoDB < TestHelpers::AWS::Base
      attr_reader :endpoint, :dynamo_db, :region

      def initialize(options)
        raise TestHelpers::AWS::NoEndpointProvided, 'No Aws Endpoint Provided' if options[:endpoint].nil?

        super options
        @dynamo_db = Aws::DynamoDB::Client.new(@aws_options)
      end

      def find_in_table_by(table_name, query_opts, options = { segments: false })
        scan_query = { table_name: table_name, select: 'ALL_ATTRIBUTES', scan_filter: {} }

        scan_query[:conditional_operator] = 'AND' if query_opts.size > 1
        query_opts.each do |key, value|
          scan_query[:scan_filter].merge!(key.to_s => { attribute_value_list: [value], comparison_operator: 'EQ' })
        end
        puts scan_query
        return scan_in_parallel(scan_query, options) if options[:segments]

        scan_in_series(scan_query)
      end

      ## This function will delete the item if found using the query_opts
      #  @return Aws::DynamoDB::Types::DeleteItemOutput
      def delete_item(table_name, query_opts)
        scan_query = {
          key: query_opts,
          table_name: table_name
        }
        @dynamo_db.delete_item(scan_query)
      end

      def scan_in_series(query)
        response = @dynamo_db.scan(query)
        items = response.items

        while response.last_evaluated_key
          new_query = query.merge(exclusive_start_key: response.last_evaluated_key)
          response = @dynamo_db.scan(new_query)
          items += response.items
        end

        items
      end

      def scan_in_parallel(query, opts)
        segments = Integer(opts[:segments])
        items = []
        segments.times do |n|
          Thread.new { items += scan_in_series(query.merge(segment: n, total_segments: segments)) }.join
        end

        items
      end
    end
  end
end
