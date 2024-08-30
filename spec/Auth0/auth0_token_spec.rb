# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

RSpec.describe TestHelpers::Auth0Token do
  context 'should raise' do
    it 'ClientIdMissing' do
      expect { TestHelpers::Auth0Token.new }.to raise_error(TestHelpers::Auth0::ClientIDMissing)
    end

    it 'ConnectionMissing' do
      expect { TestHelpers::Auth0Token.new(client_id: 'test') }.to raise_error(TestHelpers::Auth0::ConnectionMissing)
    end

    it 'GrantTypeMissing' do
      expect do
        TestHelpers::Auth0Token.new(client_id: 'test', connection: 'connection')
      end.to raise_error(TestHelpers::Auth0::GrantTypeMissing)
    end

    it 'ScopeMissing' do
      expect do
        TestHelpers::Auth0Token.new(client_id: 'test',
                                    connection: 'connection',
                                    grant_type: 'testType')
      end.to raise_error(TestHelpers::Auth0::ScopeMissing)
    end

    it 'URL Missing' do
      expect do
        TestHelpers::Auth0Token.new(client_id: 'test',
                                    connection: 'connection',
                                    grant_type: 'testType',
                                    scope: 'testScope')
      end.to raise_error(TestHelpers::Auth0::Auth0URL)
    end
  end

  context 'Methods' do
    let(:setup) do
      {
        client_id: 'test',
        connection: 'connection',
        grant_type: 'testType',
        scope: 'testScope',
        username: 'user',
        password: 'password',
        url: 'www.example.com'
      }
    end

    let(:data) { TestHelpers::Auth0Token.new(setup) }
    let(:username) { TestHelpers::Auth0Token.new(setup) }
    let(:password) { TestHelpers::Auth0Token.new(setup).password_set('newPassword') }

    describe '#get_token' do
      it 'should raise TokenGenerationError for nil response' do
        allow(RestClient::Request).to receive(:execute).and_return(RestClient::Response)
        allow(RestClient::Response).to receive(:create).and_return(nil)
        expect { TestHelpers::Auth0Token.new(setup).get_token }.to raise_error TestHelpers::Auth0::TokenGenerationError
      end

      it 'should raise TokenGenerationError if id_token is not found' do
        allow(RestClient::Request).to receive(:execute).and_return(RestClient::Response)
        allow(RestClient::Response).to receive(:create).and_return(a: 1)
        expect { TestHelpers::Auth0Token.new(setup).get_token }.to raise_error TestHelpers::Auth0::TokenGenerationError
      end
    end

    describe '#user' do
      it 'sets the user' do
        data.user_set('newUser')

        expect(data.username).to eql('newUser')
      end
    end

    describe '#password' do
      it 'sets the Password' do
        data.password_set('newPassword')
        expect(data.password).to eql('newPassword')
      end
    end

    describe '#build_user' do
      it 'sets user information' do
        data.build_user('user1', 'password1')
        expect(data.username).to eql('user1')
        expect(data.password).to eql('password1')
      end
    end
  end
end
