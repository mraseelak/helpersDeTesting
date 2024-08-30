# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

RSpec.describe 'TestHelpers::Okta' do
  describe '#configure!' do
    before do
      TestHelpers::Okta.configure!(issuer: 'https://www.example.com')
    end

    it 'should set the issuer URL' do
      expect(TestHelpers::Okta.issuer).to eql('https://www.example.com')
    end

    it 'should set the Client base_url' do
      expect(TestHelpers::Okta::Client.base_uri).to eql('https://www.example.com')
    end
  end

  describe '#user_sign_in' do
    before do
      TestHelpers::Okta.configure!(issuer: 'https://www.example.com')
    end

    it 'should raise error if username is missing' do
      expect do
        TestHelpers::Okta.user_sign_in(password: 'dd',
                                       scope: 'openid',
                                       grant_type: 'password',
                                       client_id: 'asdf',
                                       client_secret: 'fasd')
      end
        .to raise_error(ArgumentError, 'missing keyword: :username')
    end

    it 'should raise error if password is missing' do
      expect do
        TestHelpers::Okta.user_sign_in(username: 'dd',
                                       scope: 'openid',
                                       grant_type: 'password',
                                       client_id: 'asdf',
                                       client_secret: 'fasd')
      end
        .to raise_error(ArgumentError, 'missing keyword: :password')
    end

    it 'should raise error if client_id is missing' do
      expect do
        TestHelpers::Okta.user_sign_in(username: 'dd',
                                       password: 'dd',
                                       scope: 'openid',
                                       grant_type: 'password',
                                       client_secret: 'fasd')
      end
        .to raise_error(ArgumentError, 'missing keyword: :client_id')
    end

    it 'should raise error if client_secret is missing' do
      expect do
        TestHelpers::Okta.user_sign_in(username: 'dd',
                                       password: 'dd',
                                       scope: 'openid',
                                       grant_type: 'password',
                                       client_id: 'asdf')
      end
        .to raise_error(ArgumentError, 'missing keyword: :client_secret')
    end

    # context 'optional params' do
    #   it 'should not raise error if grant_type is missing' do
    #     mock = double(TestHelpers::Okta::Client)
    #     puts mock
    #     data = {username: 'dd',
    #             password: 'dd',
    #             scope: 'openid',
    #             client_secret: 'asdf',
    #             client_id: 'asdf'}
    #     allow(mock).to receive(:post).with(data).and_return(200)
    #     # TestHelpers::Okta.user_sign_in(data)
    #
    #     expect(TestHelpers::Okta.user_sign_in(data)).to eql(200)
    #   end
    #
    # end
  end
end
