## Hiptest
To work with Hiptest in order to setup test runs from hiptest on the fly

### Create a test run
```ruby
bin/hiptest_setup build_test_run  -p <HIPTEST_PROJECT_ID> -c <HIPTEST_CLIENT_ID> -a <HIPTEST_ACCESS_TOKEN> -u <HIPTEST_UID> -b <BUILD_NAME> -r <TAG> -l <App List> -d <Test Description> 
```
This will build a test run id with all the tests that match the tag provided already added to the test. If the `--run_tag` is invalid or not found, then a test run is not created 

You can add description to the test run that can inform the user about the test run using the `-d` flag

### Retrieve all the scenarios (not the tests) for the tag
```ruby
bin/hiptest_setup get_scenario_ids_by_tag  -p <HIPTEST_PROJECT_ID> -c <HIPTEST_CLIENT_ID> -a <HIPTEST_ACCESS_TOKEN> -u <HIPTEST_UID> -r <TAG>
```
This will retrieve all the scenarios that match the tags and return an array. If no tests match the tag then an empty array is returned. This can be used to skip `WIP` tests for example.


:warning: The `LIST_OF_APPLICATIONS` should be in the following format
```ruby
APP1:BUILD_NUMBER,APP2:BUILDNUMBER

example:
PA:12-12-2019-1254,PS:18-12-2019-1218
```

### create a test run for the current sprint with all the tests tagged with the same sprint name. 
Suppose you have a test tagged with the previous sprint and there is a run specifically for that sprint. Now in the new 
sprint you want to create a bunch of tests (tagged with the same sprint name), you can do so using the `sprint` command
```ruby
bundle exec hiptest_setup sprint -p <project_id_no> -a <hiptest_access_token> -c <hiptest_client_id> -u <hiptest_uid> -s <name_of_sprint>
``` 
This will collect all the scenarios that have the same tag as the `name_of_sprint` and add it to the sprint, if it exists. Else it will create one for you and add add it