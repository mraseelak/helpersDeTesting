# frozen_string_literal: true

require 'test_helpers/support'
require 'test_helpers/logger'
require 'test_helpers/Auth0/auth0_token'
require 'test_helpers/AWS/dynamo_db'
require 'test_helpers/AWS/iam'
require 'test_helpers/AWS/qldb'
require 'test_helpers/AWS/qldb_session'
require 'test_helpers/AWS/s3'
require 'test_helpers/AWS/secrets_manager'
require 'test_helpers/CloudQA/cloud_qa'
require 'test_helpers/Email/email'
require 'test_helpers/Hiptest/hiptest'
require 'test_helpers/Okta/okta_token'
require 'test_helpers/Parser/xlsx'
require 'test_helpers/Request/request'
require 'test_helpers/Request/request2'
require 'test_helpers/Request/proxy'
require 'test_helpers/version'

# This is the module that is required, to call this gem
module TestHelpers
end
