# TestHelpers
This is a gem to consolidate all the test related work for BIAD group. This gem consolidates all the boilerplate code, used in 
testing this freeing up the developer from writing them. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'test_helpers'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install test_helpers

## Usage

### As a gem
In the gemspec require your gem

```docker
gem 'test_helpers', git: 'https://github.com/BIAD/test_helpers.git'
```
#### Auth0
 The ideal way to use this gem would be to create the Auth0 object, which can then be used with username and password to get the token

 ```ruby
auth0_obj = TestHelpers::Auth0Token.new(
          connection: "<connection_string>",
          grant_type: "password",
          scope: "openid email roles",
          client_id: "<client_id>",
          url: 'https://ncimatch.auth0.com/oauth/ro',
        )

tokenObj = auth0_obj.get_token('<username>', 'password')
tokenObj.id_token # returns the token string to be used in request

or

token = auth0_obj.get_token('<username>', 'password').id_token
```
Alternately,
```ruby
token = TestHelpers::Auth0Token.new(
                  connection: "<connection_string>",
                  grant_type: "password",
                  scope: "openid email roles",
                  client_id: "<client_id>",
                  url: 'https://ncimatch.auth0.com/oauth/ro',
                  username: "<username>",
                  password: "<password>"
                ).get_token.id_token
```

#### Okta
To retrieve the okta token, you need to first configure the issuer, client and the client secret, like shown below
```ruby
TestHelpers::Okta.configure!(
  issuer: "<issuer url>", 
  client_id: "<client_id>", 
  client_secret: "<client_secret>"
)
```

Now generate the token for a username and password like so
```ruby
TestHelpers::Okta.sign_in(
  username: "<username>", 
  password: "<password>", 
  scope: "<scope>", # [optional, default is openid]
  grant_type: "<grant type>"  # [optional, default is password]
 )
```
To retrieve information
```ruby
id_token = TestHelpers::Okta.id_token
access_token = TestHelpers::Okta.access_token

# For other details
parsed_response = TestHelpers::Okta.response.parsed_response

["access_token", "token_type", "expires_in", "scope", "id_token"].each do |key|
  puts "#{key}: #{parsed_response[key]}"
end

```

### Request
This gem can be used to make rest calls. The response is in the form of a `Response` object which follows the standard
LEIDOS test team's response format.

The input is in the form of options because of the various forms the request can have.
The generic form is below

```ruby
GET

response = TestHelpers::API::Request.get(
               url: "<rest api url>",
               id_token: "<id token retrieved from Auth0>",
               headers: { key: "<value>"} # Any additional headers needed can be provided as a hash
             )
```

```ruby
POST
response = Test::API::Request.post(
               url: "<rest api url>",
               id_token: "<id token retrieved from Auth0>",
               headers: { key: "<value>"},
               payload: { key: "<value>"}
          )
```

#### Response
The response is generic in the return format
```ruby
response.class
        => TestHelpers::API::Response

TestHelpers::API::Response.instance_methods(false)
        => [:message, :backtrace, :status, :backtrace=, :http_code, :message=, :status=, :http_code=]

response.message # returns the response received

response.status # [String] Success (if response code is 20x) else Failure. 

response.http_code # [String] response code.

response.backtrace # If there is an error in the call capture the backtrace
```

### Parser
The parser provide convenient way to parse different format or files
```ruby
XLSX Parser:
xlsx = TestHelpers::Parser::Xlsx.new('your_file_path')
puts xlsx.table_hashes
```

### AWS MODULE
#### Dynamo
To create client
```ruby
client = TestHelpers::AWS::DynamoDB.new(
  endpoint: "<dyanamodb_endpoint>",
  region: "<region>",
  access_key_id: "<aws_access_key_id>",
  secret_access_key: "<aws_secret_access_key>",
  session_token: "<aws_session_token>"
)
```

To retrieve items
```ruby
client.find_in_table_by("<table_name>", "<query_opts>", segments: "<true or false defaults is false>")
``` 

To delete item
```ruby
client.delete_item(table_name, query_opts)
```
`query_opts` must contain the primary key and the secondary key (if present)

#### S3
To instantiate client
```ruby
s3_client = TestHelpers::AWS::S3.new(
  region: "<region>",
  access_key_id: "<aws_access_key_id>",
  secret_access_key: "<aws_secret_access_key>",
  session_token: "<aws_session_token>"
)
```
To list all files in a path under a bucket
```ruby
s3_client.list_files("<bucket_name>", "<path to folder under bucket_name>")
```
To check for existence of file
```ruby
s3_client.file_exists?("<bucket_name>", "<path to folder under bucket_name>", "<file_name>")
```

To delete all files or individual file, given the key (which can be the folder path or the file path under the bucket)
```ruby
s3_client.delete_files("<bucket_name>", "<key>")
```

To download files from S3 to local machine
```ruby
s3_client.download_files("<bucket_name>", "<key>", "<download target on local machine>")
``` 

#### SecretsManager
To instantiate client
```ruby
secrets_client = TestHelpers::AWS::SecretsManager.new(
  endpoint: "<dyanamodb_endpoint>",
  region: "<region>",
  access_key_id: "<aws_access_key_id>",
  secret_access_key: "<aws_secret_access_key>",
  session_token: "<aws_session_token>",
  secret_id: "<secret_id>"
)
```

To retrieve all the values in the secret as a json
```ruby
secrets_client.get_all
```

To retrieve individual values provide the key
```ruby
secrets_client.get_value(<key>)
```

### As a CLI Tool

Download the project. Then run:
```ruby
bin/setup

```
In the project root folder you can run the following commands

To get the Auth0 Token
```bash
bin/auth0 get_token_for --client_id "<client_id>" --username "<Auth0_username>" --password "<Auth0_password>" --grant_type password --scope "openid email roles name" --connection "<connection_string>" --url https://ncimatch.auth0.com/oauth/ro
```

:warning:
Currently we have only Auth0 setup for use in CLI mode. Work is in progress to get Okta too into the CLI mode
