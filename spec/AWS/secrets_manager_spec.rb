# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

RSpec.describe TestHelpers::AWS::SecretsManager do
  context 'should raise' do
    it 'SecretNameNotProvided' do
      expect { TestHelpers::AWS::SecretsManager.new({}) }.to raise_error(TestHelpers::AWS::SecretNameNotProvided)
    end

    it 'NoRegionProvided' do
      expect do
        TestHelpers::AWS::SecretsManager.new(secret_id: 'test', session_token: 'sample_token')
      end.to raise_error(TestHelpers::AWS::NoRegionProvided)
    end
  end

  context 'Methods' do
    let(:setup) do
      {
        secret_id: 'id',
        region: 'something',
        session_token: 'token',
        access_key_id: 'access_key',
        secret_access_key: 'secret_key'
      }
    end
  end
end
