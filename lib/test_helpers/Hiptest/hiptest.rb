# frozen_string_literal: true

require 'httparty'
require 'json'

module TestHelpers
  ## This module deals with the interaction with Hiptest.
  module Hiptest
    module_function

    class << self
      attr_accessor :build
      attr_reader :project
    end

    def configure_project!(project:, access_token:, client:, uid:, build: nil, tags: nil, list: nil, description: nil, name: true)
      @project = project

      headers = {
        Accept: 'application/vnd.api+json; version=1',
        "access-token": access_token,
        client: client,
        uid: uid
      }
      Scenarios.setup_scenarios(project: project, tags: tags, headers: headers)
      TestRuns.setup_test_runs(project: project, build: build, headers: headers, list: list,
                               description: description, tags: tags, name: name)
    end

    def build_test_run
      Scenarios.collect_scenarios
      scenario_list = Scenarios.scenario_id_list
      scenario_count = Scenarios.scenario_count
      return 1 unless scenario_count.positive?

      TestRuns.add_scenarios scenario_list
      TestRuns.create_test_run
      TestRuns.add_tag_list_to_id

      completed = TestRuns.wait_on_test_completion(scenario_count: scenario_count)

      raise 'Could not finish adding scenarios to test run after 100 secs' unless completed

      TestRuns.id
    end

    def collect_scenarios
      Scenarios.collect_scenarios
    end

    ## Creating a Scenarios class that contains all the necessary calls for the Scenarios
    class Scenarios
      include HTTParty

      class << self
        attr_accessor :tags
        attr_reader :response, :headers, :test_count

        ## Initializing the Scenarios class
        def setup_scenarios(project:, tags: nil, headers: {})
          base_uri "https://studio.cucumber.io/api/projects/#{project}/scenarios"
          @headers = headers
          @tags = tags.nil? ? nil : tags.split(',').map { |t| t.gsub(' ', '') }
        end

        def collect_scenarios
          if @tags.nil?
            collect_all_scenarios
          else
            collect_scenarios_by_tags
          end
          scenario_id_list
        end

        def collect_all_scenarios
          @response = get(base_uri, headers: @headers)
        rescue StandardError => e
          puts e.backtrace
          raise e
        end

        ## This will collect all the scenarios from the Hiptest project based on the tags provided
        # The list is going to be a list of scenarios which match the tag
        def collect_scenarios_by_tags(tags = nil)
          tags = @tags if tags.nil?
          raise 'Tag(s) not provided' if tags.nil?

          collexn = []
          threads = []

          # threading to make the process easier and faster
          tags.each do |t|
            threads << Thread.new(t) do |th|
              options = {
                headers: @headers,
                query: {
                  key: th
                }
              }
              resp = get('/find_by_tags', options)
              collexn << resp.parsed_response
            end
          end
          threads.each(&:join)
          @response = collexn
        rescue StandardError => e
          puts e.backtrace
          raise e
        end

        def scenarios_with_same_tags(tags)
          counter = {}
          collect_scenarios_by_tags tags
          raw_scenario_id_list.each do |id|
            counter[id] = counter[id].nil? ? 1 : counter[id] + 1
          end
          counter.collect { |k, v| k if v == tags.length }.compact
        end

        ## This function will tag the scenario list with the key and value provided
        # If value is present the tag will look like "key:value" else it will look like "key"
        # @param scenario_list: ARRAY list of scenario ids that need tagging
        # @param key: STRING (required) key part of the tag
        # @param value: STRING (optional) value part of the tag
        # @return null on success
        def add_tag_to_scenarios(scenario_list, key, value = nil)
          threads = []
          collexn = []
          attribute = { key: key, value: value }.compact
          puts attribute.class
          scenario_list.each do |sc|
            threads << Thread.new(sc) do |_th|
              payload = {
                headers: @headers,
                body: { data: { attributes: attribute } }.to_json
              }
              puts "Adding tag #{attribute.values.join(':')} to scenario with tag: #{sc}"
              resp = post("/#{sc}/tags", payload)
              collexn << resp.parsed_response
            end
          end
          threads.each(&:join)
        rescue StandardError => e
          puts e.backtrace
          puts collexn
          raise e
        end

        ## Return a list of scenarios
        def scenario_id_list
          @response.collect { |a| a['data'].collect { |b| b['id'] } }.flatten.uniq
        end

        def raw_scenario_id_list(scenarios = nil)
          scenarios ||= @response
          scenarios.collect { |a| a['data'].collect { |b| b['id'] } }.flatten
        end

        # Return a count of the scenarios collected.
        def scenario_count
          options = {
            headers: @headers
          }

          @test_count = 0
          scenario_id_list.each do |scenario|
            response = get("/#{scenario}/datasets", options)
            data = JSON.parse(response.body)['data']
            @test_count += data.length.zero? ? 1 : data.length
          end
          @test_count
        end
      end

      raise_on [404, 401, 500, 400, 403]
    end

    ## Creating a Scenarios class that contains all the necessary calls for the Test Runs
    class TestRuns
      include HTTParty

      class << self
        attr_reader :response, :scenario_id_list, :id, :options, :build, :list, :description, :project

        ## Initializing the TestRuns class
        def setup_test_runs(project:, build:, headers:, list: nil, description: nil, tags: nil, name: nil)
          @options = {
            headers: headers
          }
          @project = project
          @build = build
          @tag = name_it_true?(name) ? " - #{tags}" : ''
          @list = list
          @id = nil
          @description = description
          base_uri "https://studio.cucumber.io/api/projects/#{@project}/test_runs"
          @project
        end

        ## Adding the Scenario list to the class
        def add_scenarios(scenarios)
          @scenarios = scenarios
        end

        ## Collect all the test runs in the project
        def collect_all_test_runs
          @response = get(base_uri, @options)
        end

        def collect_active_test_runs
          @response = get('?filter[status]=active', @options)
        end

        ## Retrieve the id of a test run by the name
        # @return id: String id of the build
        def retrieve_test_run_id_by_build_name(build = nil)
          build ||= @build
          response = JSON.parse(@response.body)['data']
          required_data = response.filter { |run| run['attributes']['name'] == build }.first
          @id = required_data.nil? ? nil : required_data['id']
        rescue StandardError => err
          puts "Error raised when trying to read the response. Printing response"
          puts @response.body
          raise err
        end

        ## This function will try and retrieve a test run based on the name. If the test run is found it will retrieve
        # it's id.
        def retrieve_test_run
          return @id unless @id.nil?

          collect_active_test_runs
          retrieve_test_run_id_by_build_name
        end

        def retrieve_test_run_by_name(build)
          collect_active_test_runs
          retrieve_test_run_id_by_build_name(build)
        end

        ## Get the current synchronization status of the test run
        # The id of the test run has to be known before hand and has to be in the @id variable.
        def get_synchronization_status
          route = "/#{@id}?show_synchronization_information=true"

          @response = get(route, @options)
          JSON.parse(@response.body)
        end

        def synchronize_test_run
          route = "/#{@id}/synchronize"
          @response = post(route, @options)
        end

        def wait_till_test_synced
          do_sync = true
          max_tries = 100
          count = 0
          while do_sync
            sleep 5
            response = get_synchronization_status
            attributes = response['data']['attributes']

            do_sync = attributes['synchronization-information']['synchronizing']
            count += 1
            break if count == max_tries
          end
          raise 'Test run sync failed after 500 seconds. Try updating manually before trying this script again' if do_sync
        end

        def sync_and_wait
          response = get_synchronization_status
          synchronizing = response['data']['attributes']['synchronization-information']['synchronizing']
          unless synchronizing
            synchronize_test_run
            wait_till_test_synced
          end
        end

        ## This will create a test run and start adding scenarios from the scenario list to the test run ID
        # @return ID: Integer Id of the test run created.
        def create_test_run
          attributes = {
            name: "#{@build}#{@tag}",
            scenario_ids: @scenarios,
            description: @description
          }.compact

          body = {
            data: {
              attributes: attributes
            }
          }.to_json

          @response = post(base_uri, @options.merge(body: body))
          @id = JSON.parse(@response.body)['data']['id']
        rescue StandardError => e
          puts e.backtrace
          raise e
        end

        ## This will add scenarios from the scenario list to the test run ID
        # @return ID: Integer Id of the test run created.
        def add_scenarios_to_existing_run
          route = "/#{@id}"
          body = {
            data: {
              type: 'test_runs',
              id: @id,
              attributes: {
                "scenario_ids": @scenarios
              }
            }
          }.to_json

          @response = patch(route, @options.merge(body: body))
        rescue StandardError => e
          puts e.backtrace
          raise e
        end

        ## Converts a string of list into a hash
        # "PA:02-25-19-1631,PP:03-12-19-0929" becomes
        # {"PA"=>"02-25-19-1631", "PP"=>"03-12-19-0929"}
        def separate_tags
          return nil if @list.nil? || @list.length.zero?

          @list.split(',').map { |v| v.split(':') }.to_h
        end

        ## Collect information about the test run created.
        def test_id_info(test_id)
          @id ||= test_id
          @response = get("/#{@id}", @options)
        rescue StandardError => e
          puts e.backtrace
          raise e
        end

        def add_tag_to_id(key: nil, value: nil)
          payload = {
            body: {
              "data": {
                "attributes": {
                  "key": key,
                  "value": value
                }
              }
            }.to_json
          }
          post("/#{@id}/tags", @options.merge(payload))
        rescue StandardError => e
          puts e.backtrace
          raise e
        end

        def add_tag_list_to_id
          tag_hash = separate_tags
          return if tag_hash.nil?

          tag_hash.each_pair do |k, v|
            add_tag_to_id(key: k, value: v)
          end
        end

        def collect_info_on_test_run
          @response = get("/#{@id}/tags", @options)
          puts @response.body
        end

        def all_statuses_count
          statuses = JSON.parse(@response.body)['data']['attributes']['statuses']
          statuses.values.reduce(:+)
        end

        def all_tests_added?(count)
          test_id_info(@id)
          all_statuses_count == count
        end

        def wait_on_test_completion(scenario_count:, timeout: 20)
          counter = 0
          while counter < timeout
            completed = all_tests_added? scenario_count
            return true if completed

            counter += 1
            sleep 5
          end
          false
        end

        private

        def name_it_true?(obj)
          obj.to_s == 'true' || obj.nil?
        end
      end
      raise_on [404, 401, 500, 400, 403]
    end
  end
end
