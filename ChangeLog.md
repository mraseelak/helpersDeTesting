### 04/29/2024 - 1.2.25
* Updated version
* had to require json

### 04/29/2024 - 1.2.24
* Added rescue and logging to hiptest

### 04/11/2024 - 1.2.23
* Update gem versions to the latest one wherever applicable

### 02/28/2024 - 1.2.22
* Update gem version for nokogiri 

### 01/18/2024 - 1.2.21
* Update hiptest_setup function to simply return a zero when there are no tests found with the sprint id

### 01/18/2024 - 1.2.20
* Update hiptest_setup function to not raise an error if a sprint name is not found. This will only print message and return a 0
* Updated tests

### 01/23/2023 - 1.2.19
* Update cucumber api url

### 01/23/2023 - 1.2.18
* Update cucumber api url

### 01/23/2023 - 1.2.17
* Update httparty to version >= 0.21.0

### 04/14/2022 - 1.2.11
* Based on dependabot alert received on downstream projects, updating nokogiri version to ~>1.13.
So any version of nokogiri up to (not including) 1.14

### 03/01/2022 - 1.2.10
* upgrade nokogiri to 1.13.2 or above

### 02/02/2022 - 1.2.9
* hiptest_setup - Add scnearios to the run ONLY if there is something to add. Cucumber IO now returns an error if you try to add null scnerios to a run. 

### 12/06/2021 - 1.2.8
* hiptest_setup - retrieve test run id will pull in only runs that are active.
This should speed up retrieval of test run when querying for test run by name.

### 11/05/2021 - 1.2.7
* hiptest_setup - When trying to move tests tagged with one tag to another one, earlier there used to be an error
when the tests with the "source" tag was not found. It is possible that the tag does not exist in a particular run. 
This patch will remove that error and this time update the destination tag and return the hiptest id of the destination 
tag

### 07/14/2021 - 1.2.6
* exposed the workbook object

### 07/14/2021 - 1.2.5
* Added functionality to retrieve details of file in s3.

### 06/08/2021 - 1.2.4
* This version lets you add a tag to a scenario list. the hiptest help command can provide more details. 
* Raise and display error when the AWS credentials have expired on Request and Proxy modules 

### 12/08/2020 - 1.2.3
* Fix a typo

### 12/07/2020 - 1.2.2
* Fix issue with `sprint` command under bin/hiptest_setup. 
   
   First it will check for the presence of that test run. If present will update the scenarios present within
   If not it will create a scenario with all the scenarios with the tag. 
   If neither of them are found then will raise an error

### 10/20/2020 - 1.2.1
* Updating the response object's to_s function

### 09/3/2020 - 1.2.0
* Added new method trigger_cloudqa_test to trigger a CloudQA test or suite
* Added new method get_cloudqa_result to get a CloudQA test or suite result
* Added new method run_cloudqa to fully run and return the results of a CloudQA test or suite
* Added documentation on how to use new CloudQA helper functions

### 09/02/2020 - 1.1.8
* Added new functions in the hiptest module.
* create a test run with scenarios that have the same name as the tstrun
* Can add tests to a specific test run. This will help move tests into regression. 

### 07/23/2020 - 1.1.7
* Added new methods #row_hash_new and #table_hashes_new with named parameters
* in Parser we now have the option to access a sheet by name or by their ordinal number
* Minor update: Added method call to TestHelpers::API::Response
* Added QLDB and QLDB Session to the gem. 
:warning: As if this date AWS does not support ruby implementation of QLDB client. Hence if you wish to read from QLDB Session. You will receive a binary stream with ASCII text that can be safely parsed in as a whole text. So if you are looking for data in this stream convert it into text and read try to find the data as a regex.

### 04/30/2020 - 1.1.5
* Added the capability to send in multiple tags. Now when the test run is being built, we can have multiple tags in 
there. 

### 03/25/2020 - 1.1.4
* Fixing issues with different types of error response from proxy client

### 03/25/2020 - 1.1.3
* Fixed issue with error message management

### 01/10/2020 - 1.1.2
* Updated rake to use `12.3` based on Github security alert

### 01/10/2020 - 1.1.1
Added compact to remove any null values in the payload for Proxy as Lambda tends to throw an error

### 01/10/2020 - 1.1.0
* Added functionality to invoke Lambda client to test the any lambda function.
* Added url method to response object. Now we can query for the url used to make request after the request has been sent. The same can be retireved fromt he response object.

### 11/25/2019 - 1.0.4
* Made Okta.client_sign_in parameter scope optional

### 10/16/2019 - 1.0.3
* Bug fixes for Hiptest

### 10/16/2019 - 1.0.2
* Updated Release

### 10/16/2019 - 1.0.1
* updated version to 1.0.1
* Minor change to add the headers to the response object.

### 09/17/2019 - 1.0.0
* updated version to 1.0.0
* This is not backward compatible and is a breaking version. Auto coversion of payload to json is no longer accepted. If json is required for your call please covert it to json. 
  If you wish to continue using hash for payload (but the application will accpet only json) please lock your version to the previous version of 0.6.5

### 08/12/2019 - 0.6.5
* Updated version to 0.6.5
* Corrected rescue block

### 08/12/2019 - 0.6.4
* Updated version to 0.6.4
* Added functionality to upload file to AWS s3 bucket.
* Added cli tool to perform the operation

### 08/12/2019 - 0.6.3
* Updated version to 0.6.3
* Added the option to have payload to delete request. If present it will add the payload to the request.

### 08/12/2019 - 0.6.2
* Updated version to 0.6.2
* Removed unnecessary logs

### 06/25/2019 - 0.6.1
* Updated version to 0.6.1
* Removed a log message that causes calling shell command to error out. 

### 06/11/2019 - 0.6.0
* Updated version to 0.6.0
* Added more functionality to email in terms of delete. 
* Upgraded to version 0.6.0 because there is a breaking change in the way certains functions are  being called. 

### 06/11/2019 - 0.5.1
* Updated version to 0.5.1
* Fixing typo  

### 06/11/2019 - 0.5.0
* Updated version to 0.5.0
* Added email module to TestHelpers.  
* this includes the feature to search and retrieve emails by subject or by body
* Also retrieve the last email after a certain time stamp.  

### 04/17/2019 - 0.4.14
* Updated version to 0.4.14
* Changes the Hiptest cli to make description an tag optional fields. If present the description or the tags are added. 

### 04/01/2019 - 0.4.13
* Updated version to 0.4.13
* Changed the CLI setting to return entire response if no key is provided.

### 04/01/2019 - 0.4.11
* Updated version to 0.4.11
* Added user_sign_in and client_sign_in CLI functionality for OKTA

### 03/21/2019 - 0.4.10
* Updated version to 0.4.10
* Added skip build hiptest test run if there are no scenarios for a tag. 
* Added wait condition for the hiptest to finish adding all the scenarios to the test run. 
* Removed add_tags_to_test_run_id function. 

### 03/12/2019 - 0.4.9
* Updated version to 0.4.9
* Added hiptest CLI tool to setup test run ids.

### 03/07/2019 - 0.4.8
* Updated version to 0.4.8
* Added code to validate and retrieve AWS IAM credentials
* These credential headers are used to validate requests going to AWS.

### 02/20/2019 - 0.4.7
* Updated version to 0.4.7
* Code refactor to DRY up. Had code reviewed to get the best practices in.  

### 02/04/2019 - 0.4.6
* Updated version to 0.4.6
* Added Delete item function to AWS::DynamoDB module
    * By providing the query opts as a hash and the table name the user can now delete item from the dynamo db table
    * Query hash should contain the primary and secondary key (if present) to delete. 

### 01/23/2019 - 0.4.5
* Updated version to 0.4.5
* Made the AWS_SESSION as optional

### 01/23/2019 - 0.4.0
* Updated version to 0.4.0
* Added Secretsmanager as a CLI (for travis)
* This can also be called from within another ruby program.

### 01/07/2019 - 0.3.0
* Updated version to 0.3.0
* Under Okta:
    * Added client_sign_in method 
    * updated the regular sign_in method to use user_sign_in.

### 01/01/2019 - 0.2.4
* Updated version to 0.2.4
* Included Okta sign in method built in httparty.
* With Okta now you can configure the Issuer, Client and the Client Secret ahead of time and 
  retrieve access token for user by providing the username and password. 

### 12/10/2018 - 0.2.3
* Updated version to 0.2.3
* Skipped vversion 0.2.2 as it was released with the wrong version and tag.

### 12/10/2018 - 0.2.1
* Updated version to 0.2.1
* This is possible breaking change. Updated the gem list to remove aws-sdk version2. From now on we
  are using the individual gems for s3 or dynamodb. This should reduce the overall footprint. 
* Added rubocop yml file to tailor the rubocop linter to check relevant issues. 
* Updated code to be more rubocop compliant.  

### 10/24/2018 - 0.1.14
* Updated version to 0.1.14
* This update adds Xlsx parser using roo to the gem.

### 08/29/2018 - 0.1.11
* updated the version to 0.1.11
* This update is in prepearation to upgrade the test_helpers version to 1.0.0. Remaining activities are to update the aws gems to use version 3 and the dynamo_helpers to the latest version. 

### 07/02/2018 - 0.1.10
* Updated version to 0.1.10
* If the response message responds to a body then save the body. Else save the enire response as a string. 

### 07/02/2018 - 0.1.9
* Updated version to 0.1.9
* Added Delete functionality to Request

### 06/11/2018 - 0.1.8
* Updated version to 0.1.8
* Added JSON rescue. We are currently expecting a JSON parseable string to be returned.
In case that does not happen TestHelpers should return the response as a string

### 05/31/2018 - 0.1.7
* Updated version to 0.1.7
* Removed all header settings for content_type and accept

### 05/30/2018 - 0.1.6
* Updated version to 0.1.6
* Bug fixes on put and patch requests.

### 05/25/2018 - 0.1.5
* Updated version to 0.1.5
* Bug fixes on all requests.

### 05/25/2018 - 0.1.4
* Updated version to 0.1.4
* Bug fixes on post request.

### 05/24/2018 - 0.1.3
* Updated version to 0.1.3
* Check for content_type and assign default type to json
* Added Unit tests

### 05/14/2018 - 0.1.2
* Updated version to 0.1.2
* Added Dynamodb functionality from Damir's dynamodb_helper gem.
* Added aws_base.rb to be used as parent for all AWS options.
