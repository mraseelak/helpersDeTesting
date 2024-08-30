# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TestHelpers::API::Request do
  context 'should' do
    it 'raise ArgumentError' do
      expect { TestHelpers::API::Request.new }.to raise_error(ArgumentError, 'missing keyword: :url')
    end

    it 'raise NoURLProvided' do
      expect { TestHelpers::API::Request.new(url: nil) }.to raise_error(TestHelpers::API::NoURLProvided)
    end

    it 'raise NoTokenProvided if auth0_on is not provided' do
      expect { TestHelpers::API::Request.new(url: 'test/url') }.to raise_error(TestHelpers::API::NoTokenProvided)
    end

    it 'raise NoTokenProvided if auth0_on is true' do
      expect { TestHelpers::API::Request.new(url: 'test/url') }.to raise_error(TestHelpers::API::NoTokenProvided)
    end

    it 'not raise NoTokenProvided if auth0_on is false' do
      expect { TestHelpers::API::Request.new(url: 'test/url', auth0_on: false) }.to_not raise_error
    end
  end

  context 'Methods' do
    let(:setup) do
      {
        url: 'example.com',
        id_token: 'token_string'
      }
    end

    let(:request) { TestHelpers::API::Request.new(**setup) }

    describe '#new' do
      it 'adds authorization to the header' do
        expect(request.headers).to include('Authorization')
      end

      it 'adds id_token to the Authorization in the header' do
        expect(request.headers['Authorization']).to eql('Bearer token_string')
      end

      it 'creates response object' do
        expect(request.response).to be_an_instance_of(TestHelpers::API::Response)
      end
    end

    describe '#post' do
      let(:req) do
        {
          url: 'example.com',
          id_token: 'token_string',
          payload: { key: 'value' }.to_json
        }
      end

      before do
        @resp = double(RestClient::Response)
        allow(@resp).to receive(:body).and_return(' { "key": "value" } ')
        allow(@resp).to receive(:headers).and_return(content_type: 'somthing')

        allow(RestClient::Request).to receive(:execute).with(
          {
            url: 'example.com',
            method: :post,
            verify_ssl: false,
            payload: { key: 'value' }.to_json,
            headers: { 'Authorization' => 'Bearer token_string' },
            timeout: 120
          }
        ).and_return(@resp)
      end

      it 'returns a status of success if the return code is 200' do
        allow(@resp).to receive(:code).and_return(200)

        response = TestHelpers::API::Request.new(url: 'example.com',
                                                 id_token: 'token_string',
                                                 payload: { key: 'value' }.to_json).post
        expect(response.status).to eql('Success')
      end

      it 'returns a status of success if the return code is 2xx' do
        allow(@resp).to receive(:code).and_return(202)
        response = TestHelpers::API::Request.new(**req).post
        expect(response.status).to eql('Success')
      end

      it 'returns a status of success if the return code is not 2xx' do
        allow(@resp).to receive(:code).and_return(404)
        response = TestHelpers::API::Request.new(**req).post
        expect(response.status).to eql('Failure')
      end

      it 'returns a message that is JSON parsed' do
        allow(@resp).to receive(:code).and_return(200)
        response = TestHelpers::API::Request.new(**req).post
        expect(response.message).to eql('key' => 'value')
      end

      it 'returns a string if the response is a string' do
        allow(@resp).to receive(:code).and_return(200)
        allow(@resp).to receive(:body).and_return('This is a string')
        response = TestHelpers::API::Request.new(**req).post
        expect(response.message).to eql('This is a string')
      end
    end

    describe '#put' do
      let(:req) do
        {
          url: 'example.com',
          id_token: 'token_string',
          payload: {
            'key': 'value'
          }
        }
      end

      before do
        @resp = double(RestClient::Response)
        allow(@resp).to receive(:body).and_return("key": 'value')
        allow(@resp).to receive(:headers).and_return(content_type: 'somthing')

        allow(RestClient::Request).to receive(:execute).with(
          {
            url: 'example.com',
            method: :put,
            verify_ssl: false,
            payload: { 'key': 'value' },
            headers: { 'Authorization' => 'Bearer token_string' },
            timeout: 120
          }
        ).and_return(@resp)
      end

      it 'returns a status of success if the return code is 200' do
        allow(@resp).to receive(:code).and_return(200)

        response = TestHelpers::API::Request.new(**req).put
        expect(response.status).to eql('Success')
      end

      it 'returns a status of success if the return code is 2xx' do
        allow(@resp).to receive(:code).and_return(202)

        response = TestHelpers::API::Request.new(**req).put
        expect(response.status).to eql('Success')
      end

      it 'returns a status of failure if the return code is not 2xx' do
        allow(@resp).to receive(:code).and_return(404)
        response = TestHelpers::API::Request.new(**req).put
        expect(response.status).to eql('Failure')
      end

      it 'returns a message that is JSON parsed' do
        allow(@resp).to receive(:code).and_return(200)
        response = TestHelpers::API::Request.new(**req).put
        expect(response.message).to eql('key' => 'value')
      end

      it 'returns a string if the response is a string' do
        allow(@resp).to receive(:code).and_return(200)
        allow(@resp).to receive(:body).and_return('This is a string')
        response = TestHelpers::API::Request.new(**req).put
        expect(response.message).to eql('This is a string')
      end
    end

    describe '#patch' do
      let(:req) do
        {
          url: 'example.com',
          id_token: 'token_string',
          payload: { 'key': 'value' }
        }
      end

      before do
        @resp = double(RestClient::Response)
        allow(@resp).to receive(:body).and_return(key: 'value')
        allow(@resp).to receive(:headers).and_return(content_type: 'somthing')

        allow(RestClient::Request).to receive(:execute).with(
          {
            url: 'example.com',
            method: :patch,
            verify_ssl: false,
            payload: { 'key': 'value' },
            headers: { 'Authorization' => 'Bearer token_string' },
            timeout: 120
          }
        ).and_return(@resp)
      end

      it 'returns a status of success if the return code is 200' do
        allow(@resp).to receive(:code).and_return(200)
        response = TestHelpers::API::Request.new(**req).patch
        expect(response.status).to eql('Success')
      end

      it 'returns a status of success if the return code is 2xx' do
        allow(@resp).to receive(:code).and_return(202)
        response = TestHelpers::API::Request.new(**req).patch
        expect(response.status).to eql('Success')
      end

      it 'returns a status of failure if the return code is not 2xx' do
        allow(@resp).to receive(:code).and_return(404)
        response = TestHelpers::API::Request.new(**req).patch
        expect(response.status).to eql('Failure')
      end

      it 'returns a message that is JSON parsed' do
        allow(@resp).to receive(:code).and_return(200)
        response = TestHelpers::API::Request.new(**req).patch
        expect(response.message).to eql('key' => 'value')
      end
      it 'returns a string if the response is a string' do
        allow(@resp).to receive(:code).and_return(200)
        allow(@resp).to receive(:body).and_return('This is a string')
        response = TestHelpers::API::Request.new(**req).patch
        expect(response.message).to eql('This is a string')
      end
    end

    describe '#get' do
      let(:req) do
        {
          url: 'example.com',
          id_token: 'token_string'
        }
      end

      before do
        @resp = double(RestClient::Response)
        allow(@resp).to receive(:body).and_return(' { "key": "value" } ')
        allow(@resp).to receive(:headers).and_return(content_type: 'somthing')

        allow(RestClient::Request).to receive(:execute).with(
          {
            url: 'example.com',
            method: :get,
            verify_ssl: false,
            headers: { 'Authorization' => 'Bearer token_string' }
          }
        ).and_return(@resp)
      end

      it 'returns a status of success if the return code is 200' do
        allow(@resp).to receive(:code).and_return(200)
        response = TestHelpers::API::Request.new(**req).get
        expect(response.status).to eql('Success')
      end

      it 'returns a status of success if the return code is 2xx' do
        allow(@resp).to receive(:code).and_return(202)
        response = TestHelpers::API::Request.new(**req).get
        expect(response.status).to eql('Success')
      end

      it 'returns a status of failure if the return code is not 2xx' do
        allow(@resp).to receive(:code).and_return(404)
        response = TestHelpers::API::Request.new(**req).get
        expect(response.status).to eql('Failure')
      end

      it 'returns a message that is JSON parsed' do
        allow(@resp).to receive(:code).and_return(200)
        response = TestHelpers::API::Request.new(**req).get
        expect(response.message).to eql('key' => 'value')
      end

      it 'returns a string if the JSON cannot be parsed' do
        allow(@resp).to receive(:code).and_return(200)
        allow(@resp).to receive(:body).and_return('This is a string')
        response = TestHelpers::API::Request.new(**req).get
        expect(response.message).to eql('This is a string')
      end

      it 'returns a success code if the response is a string' do
        allow(@resp).to receive(:code).and_return(200)
        allow(@resp).to receive(:body).and_return('This is a string')
        response = TestHelpers::API::Request.new(**req).get
        expect(response.http_code).to eql('200')
      end
    end

    describe '#delete' do
      let(:req) do
        {
          url: 'example.com',
          id_token: 'token_string'
        }
      end

      before do
        @resp = double(RestClient::Response)
        allow(@resp).to receive(:body).and_return(' { "key": "value" } ')
        allow(@resp).to receive(:headers).and_return(content_type: 'somthing')

        allow(RestClient::Request).to receive(:execute).with(
          {
            url: 'example.com',
            method: :delete,
            verify_ssl: false,
            headers: { 'Authorization' => 'Bearer token_string' }
          }
        ).and_return(@resp)
      end

      it 'returns a status of success if the return code is 200' do
        allow(@resp).to receive(:code).and_return(200)
        response = TestHelpers::API::Request.new(**req).delete
        expect(response.status).to eql('Success')
      end

      it 'returns a status of success if the return code is 2xx' do
        allow(@resp).to receive(:code).and_return(202)
        response = TestHelpers::API::Request.new(**req).delete
        expect(response.status).to eql('Success')
      end

      it 'returns a status of failure if the return code is not 2xx' do
        allow(@resp).to receive(:code).and_return(404)
        response = TestHelpers::API::Request.new(**req).delete
        expect(response.status).to eql('Failure')
      end

      it 'returns a message that is JSON parsed' do
        allow(@resp).to receive(:code).and_return(200)
        response = TestHelpers::API::Request.new(**req).delete
        expect(response.message).to eql('key' => 'value')
      end

      it 'returns a string if the JSON cannot be parsed' do
        allow(@resp).to receive(:code).and_return(200)
        allow(@resp).to receive(:body).and_return('This is a string')
        response = TestHelpers::API::Request.new(**req).delete
        expect(response.message).to eql('This is a string')
      end

      it 'returns a success code if the response is a string' do
        allow(@resp).to receive(:code).and_return(200)
        allow(@resp).to receive(:body).and_return('This is a string')
        response = TestHelpers::API::Request.new(**req).delete
        expect(response.http_code).to eql('200')
      end
    end
  end
end
