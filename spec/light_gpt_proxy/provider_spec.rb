# frozen_string_literal: true

RSpec.describe LightGptProxy::Provider do
  subject { described_class.new(name: 'open_ai', config:) }

  let!(:config_path) { File.join(Dir.pwd, 'spec/support/configs/.light_gpt_proxy.yml') }
  let!(:config) { YAML.load_file(config_path).dig('providers', 'open_ai') }

  it '#index returns definitions of all endpoints' do
    index = subject.index
    expect(index).to be_a(Array)
    expect(index.map { |h| h[:name] }).to eq(%w[completions models])
    completions = index.find { |h| h[:name] == 'completions' }
    expect(completions[:method]).to eq('POST')
    expect(completions[:path]).to eq('v1/chat/completions')
    expect(completions[:schema]).to be_a(Hash)
    models = index.find { |h| h[:name] == 'models' }
    expect(models[:method]).to eq('GET')
    expect(models[:path]).to eq('v1/models')
    expect(models[:schema]).to be_nil
  end

  it '#endpoint returns array of endpoint instances' do
    endpoints = subject.endpoints
    expect(endpoints).to be_a(Array)
    expect(endpoints.map(&:class)).to eq([LightGptProxy::Endpoint, LightGptProxy::Endpoint])
  end

  it '#find_endpoint returns endpoint instance' do
    endpoint = subject.find_endpoint('completions')
    expect(endpoint).to be_a(LightGptProxy::Endpoint)
    expect(endpoint.name).to eq('completions')
  end

  context '#perform_request' do
    it 'raises error if endpoint not found' do
      expect { subject.perform_request('not_found') }.to raise_error(ArgumentError, "Endpoint 'not_found' not found")
    end

    it 'raises error if payload is invalid' do
      expect { subject.perform_request('completions', {}) }.to raise_error
    end

    it 'performs request' do
      endpoint = subject.find_endpoint('models')
      allow(endpoint).to receive(:execute_request).and_return('response')
      expect(subject.perform_request('models')).to eq('response')
    end
  end
end
