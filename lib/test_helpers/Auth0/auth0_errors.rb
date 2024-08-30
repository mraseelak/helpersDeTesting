# frozen_string_literal: true

module TestHelpers
  module Auth0
    class Error < StandardError
    end

    class NoUsernameProvided < Error; end

    class MissingPassword < Error; end

    class TokenGenerationError < Error; end

    class ClientIDMissing < Error; end

    class GrantTypeMissing < Error; end

    class ConnectionMissing < Error; end

    class ScopeMissing < Error; end

    class Auth0URL < Error; end
  end
end
