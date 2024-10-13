# frozen_string_literal: true
require 'rack/test'

RSpec.describe LightGptProxy::ProxyServer do
  include Rack::Test::Methods

  def app
    LightGptProxy::ProxyServer
  end

  before do
    allow(LightGptProxy).to receive(:VERSION).and_return('1.0.0')
    allow(LightGptProxy).to receive(:providers).and_return(['open_ai', 'copilot'])
    allow(LightGptProxy).to receive(:default_provider).and_return('open_ai')
  end

  describe 'GET /health' do
    it 'returns a successful health status' do
      get '/health'
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(JSON.parse(last_response.body)).to eq({ 'status' => 'ok' })
    end
  end

  describe 'GET /' do
    it 'returns the root information' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')

      body = JSON.parse(last_response.body)
      expect(body['status']).to eq("LightGptProxy #{LightGptProxy::VERSION} is running")
      expect(body['providers']).to eq(['open_ai', 'copilot'])
      expect(body['default_provider']).to eq('open_ai')
      expect(body['help'].join).to include('GET  /:provider')
    end
  end

  describe 'GET /:provider' do
    context 'when provider exists' do
      it 'returns the provider index' do
        allow(LightGptProxy).to receive(:provider).with('open_ai').and_return(double(index: ['endpoint_1', 'endpoint_2']))

        get '/open_ai'
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        expect(JSON.parse(last_response.body)).to eq(['endpoint_1', 'endpoint_2'])
      end
    end

    context 'when provider does not exist' do
      it 'returns a 404 with error message' do
        allow(LightGptProxy).to receive(:provider).with('unknown').and_raise(ArgumentError, 'Provider not found')

        get '/unknown'
        expect(last_response.status).to eq(404)
        expect(last_response.content_type).to eq('application/json')

        body = JSON.parse(last_response.body)
        expect(body.dig('error', 'message')).to eq('Provider not found')
        expect(body['source']).to eq('proxy_server')
      end
    end
  end

  describe 'POST /:provider/:endpoint' do
    context 'when request is valid' do
      it 'proxies the request to the provider' do
        provider_double = double
        allow(provider_double).to receive(:perform_request).with('test_endpoint', 'test_body').and_return({ result: 'success' })
        allow(LightGptProxy).to receive(:provider).with('open_ai').and_return(provider_double)

        post '/open_ai/test_endpoint', 'test_body'
        expect(last_response.status).to eq(200)
        expect(last_response.content_type).to eq('application/json')
        expect(JSON.parse(last_response.body)).to eq({ 'result' => 'success' })
      end
    end

    context 'when provider or endpoint is invalid' do
      it 'returns a 404 with error message' do
        allow(LightGptProxy).to receive(:provider).with('open_ai').and_raise(ArgumentError, 'Invalid provider or endpoint')

        post '/open_ai/invalid_endpoint', 'test_body'
        expect(last_response.status).to eq(404)
        expect(last_response.content_type).to eq('application/json')

        body = JSON.parse(last_response.body)
        expect(body.dig('error', 'message')).to eq('Invalid provider or endpoint')
        expect(body['source']).to eq('proxy_server')
      end
    end
  end
end
