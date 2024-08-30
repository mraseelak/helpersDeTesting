# frozen_string_literal: true

require 'httparty'

module TestHelpers
  class CloudQA
    include HTTParty
    attr_accessor :app_base_url, :browser, :cloudqa_base_url, :params
    attr_reader :test_suite_url, :test_case_url

    def initialize(app_base_url:, cloudqa_api_key:, browser: 'Chrome', cloudqa_base_url: 'https://app.cloudqa.io/api', params: {})
      # Setting up values used when making requests
      @headers = {
        "Authorization": "ApiKey #{cloudqa_api_key}",
        "Content-Type": 'application/json'
      }
      @body = {
        "Browser": browser,
        "BaseUrl": app_base_url,
        "Variables": params
      }.to_json
      @cloudqa_base_url = cloudqa_base_url

      # Setting attr_accessor values
      @app_base_url = app_base_url
      @browser = browser
      @params = params
      @test_case_url = "#{@cloudqa_base_url}/v1/testcases"
      @test_suite_url = "#{@cloudqa_base_url}/v1/suites"
    end

    def trigger_cloudqa_test(type:, test_id:, display_msg: true)
      raise 'Please provide one of the following valid CloudQA "type" values: "case", "suite"' unless %w[case suite].include? type

      case type
      when 'case'
        url = "#{@test_case_url}/#{test_id}/runs"
      when 'suite'
        url = "#{@test_suite_url}/#{test_id}/runs"
      end

      response = HTTParty.post(url, { body: @body, headers: @headers })
      if display_msg == true
        puts "Triggering CloudQA test #{type} #{test_id}..."
        puts response
      end
      response
    end

    def get_cloudqa_result(type:, test_id:, run_id:, return_response: 'complete', display_msg: true)
      raise 'Please provide one of the following valid CloudQA "type" values: "case", "suite"' unless %w[case suite].include? type
      raise 'Please provide one of the following valid "return_response" response values: "complete", "parsed"' unless %w[complete
                                                                                                                          parsed].include? return_response

      case type
      when 'case'
        url = "#{@test_case_url}/#{test_id}/runs/#{run_id}"
      when 'suite'
        url = "#{@test_suite_url}/#{test_id}/runs/#{run_id}"
      end

      response = HTTParty.get(url, headers: @headers)
      if display_msg == true
        puts "Retrieving CloudQA test #{type} run #{run_id}..."
        puts response
      end

      case return_response
      when 'complete'
        response
      when 'parsed'
        case type
        when 'case'
          status = response['status'].downcase
        when 'suite'
          status = response['result'].downcase
        end
        status
      end
    end

    def run_cloudqa(type:, test_id:, timeout: 60)
      raise 'Please provide one of the following valid CloudQA "type" values: "case", "suite"' unless %w[case suite].include? type
      raise '"timeout" should be an Integer' unless timeout.is_a?(Integer)

      response = trigger_cloudqa_test(type: type, test_id: test_id, display_msg: true)
      run_id = capture_id(type: type, response: response)
      validate_response_values(type: type, run_id: run_id, response: response)
      status = wait_for_run_completion(type: type, timeout: timeout, test_id: test_id, run_id: run_id)
      report_status(type: type, test_id: test_id, run_id: run_id, status: status)

      status
    end

    private

    def capture_id(type:, response:)
      raise "Type: #{response} is invalid" unless %w[case suite].include? type

      return response['id'] if type == 'case'

      response['runId']
    end

    def validate_response_values(type:, run_id:, response:)
      if run_id.nil?
        raise "CloudQA has changed the key used for referencing the test #{type} run id. test_helpers needs to be updated accordingly."
      end

      case type
      when 'case'
        if response['status'].nil?
          raise 'CloudQA has changed the key used for referencing the test run status. test_helpers needs to be updated accordingly.'
        end
      when 'suite'
        if response['result'].nil?
          raise 'CloudQA has changed the key used for referencing the suite run result. test_helpers needs to be updated accordingly.'
        end
      end
    end

    def wait_for_run_completion(type:, timeout:, test_id:, run_id:)
      raise '"type" should be either "case"(test case) or "suite"(test suite)' unless %w[case suite].include? type

      start_time = Time.now

      while Time.now < start_time + 60 * timeout

        status = get_cloudqa_result(type: type, test_id: test_id, run_id: run_id, return_response: 'parsed', display_msg: false)

        break if %w[passed failed].include? status

        time_passed = Time.now - start_time
        puts "#{time_passed.round} seconds have elapsed. Next update in ~10 seconds. Current status of test #{type} run #{run_id}: #{status}."
        sleep 10
      end

      status
    end

    def report_status(type:, test_id:, run_id:, status:)
      if %w[passed failed].include? status
        puts "Test #{type} '#{test_id}' completed #{type} run '#{run_id}'. The test #{type} #{status}."
      else
        puts "Test #{type} '#{test_id}' has not completed #{type} run '#{run_id}'. The last #{type} result was #{status}."
      end
    end
  end
end
