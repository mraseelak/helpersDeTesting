## Setup instructions to use the CloudQA class:
1) Log into your CloudQA account.
2) Go to the "My Account" page on CloudQA.
3) Generate an "API Key" for your account if you haven't already. Copy your personal account's "API Key" (make sure to copy the entire key).
4) **Optional**: Create an environment variable on your local machine and set it equal to your personal CloudQA account's "API Key".

## How to initialize a valid CloudQA object:
1) Provide a valid "app_base_url" value, which are urls for the application you want make CloudQA API calls on.
    For example, to test the int tier of STRAP, a valid url would be: "https://strap.trials-int.nci.nih.gov"
2) Provide a valid "cloudqa_api_key" value, from your personal CloudQA account.

## Optional parameters when initializing a CloudQA object:
1) Valid "browser" values: "Chrome", "Firefox", "IE"
2) Valid "params" values: Provide key & value pairs in a hash
    Example: 
    ```
    { "key_1": "abc", "key_2": "123" }
    ```
3) For flexibility purposes in the class, allowing user to change the "cloudqa_base_url" value in case a new CloudQA API URL is added in the future

## Optional parameters used in CloudQA functions:
1) **display_msg** (**Functions: trigger_cloudqa_test, get_cloudqa_result**) ->  Set to **true** or **false** to control whether info message is displayed (**Default value: true**)
2) **return_response** (**Functions: get_cloudqa_result**) -> Set to **'complete'** or **'parsed'** to control whether the object returned is a complete json or a parsed test result string (**Default value: 'complete'**)
3) **timeout** (**Functions: run_cloudqa**) -> Set a whole number deciding how long (in minutes) the function will wait for the run result before timing out (**Default value: 60**)

## Usage Examples:

### Object Initialization
#### Example with required fields only
```ruby
caller = TestHelpers::CloudQA.new(app_base_url: "https://strap.trials-int.nci.nih.gov", cloudqa_api_key: ENV["PERSONAL_CLOUDQA_API_KEY"])
```
#### Example with required & optional fields
```ruby
caller = TestHelpers::CloudQA.new(app_base_url: "https://strap.trials-int.nci.nih.gov", cloudqa_api_key: ENV["PERSONAL_CLOUDQA_API_KEY"], browser: "IE", params: {"key": "value"})
```

### Example Function Calls
```ruby
# triggers a CloudQA test case run, returns json detailing whether test case run trigger was successful
caller.trigger_cloudqa_test(type: 'case', test_id: 23907)
# triggers a CloudQA test suite run, returns json detailing whether test suite run trigger was successful
caller.trigger_cloudqa_test(type: 'suite', test_id: 1960)
# returns json with specific CloudQA test case run's result
caller.get_cloudqa_result(type: 'case', test_id: 23907, run_id: 2879880) 
# returns json with specific CloudQA test suite run's result
caller.get_cloudqa_result(type: 'suite', test_id: 1960, run_id: 94962) 
# triggers a CloudQA test case run, waits for test case run to finish, returns string with test case run result
caller.run_cloudqa(type: 'case', test_id: 23857) 
# triggers a CloudQA test suite run, waits for test suite run to finish, returns string with test suite run result
caller.run_cloudqa(type: 'suite', test_id: 1978) 
```
