# frozen_string_literal: true

module TestHelpers
  module AWS
    class NoEndpointProvided < StandardError; end

    class NoRegionProvided < StandardError; end

    class NoAccessKeyProvided < StandardError; end

    class NoSecretAccessKeyProvided < StandardError; end

    class NoBucketProvided < StandardError; end

    class NoPathProvided < StandardError; end

    class FileNotFound < StandardError; end

    class SecretNameNotProvided < RuntimeError; end

    class NoSessionTokenFound < RuntimeError; end

    class NoFunctionNameProvided < RuntimeError; end
  end
end
