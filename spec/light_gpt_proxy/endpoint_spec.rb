# frozen_string_literal: true

RSpec.describe LightGptProxy::Endpoint do
  subject { described_class.new(name:, path:, host:, key:, method:, body_schema:, header_options:) }
  let!(:config_path) { File.join(Dir.pwd, 'spec/support/configs/.light_gpt_proxy.yml') }
  let!(:config) { YAML.load_file(config_path).dig('providers', 'open_ai') }

  context '#models endpoint', :vcr do
    let!(:name) { 'models' }
    let!(:path) { config.dig('endpoints', name, 'path') }
    let!(:host) { config['host'] }
    let!(:key) { config['api_key'] }
    let!(:method) { config.dig('endpoints', name, 'method') }
    let!(:body_schema) { config.dig('endpoints', name, 'body_schema') }
    let!(:header_options) { config.dig('endpoints', name, 'header_options') }

    it '#execute_request' do
      response = subject.execute_request
      expect(response).to be_a(Hash)
      expect(response.keys).to match_array(%w[object data])
    end
  end

  context '#completions endpoint', :vcr do
    let!(:name) { 'completions' }
    let!(:path) { config.dig('endpoints', name, 'path') }
    let!(:host) { config['host'] }
    let!(:key) { config['api_key'] }
    let!(:method) { config.dig('endpoints', name, 'method') }
    let!(:body_schema) { config.dig('endpoints', name, 'body_schema') }
    let!(:header_options) { config.dig('endpoints', name, 'header_options') }

    context '#execute_request' do
      let!(:correct_payload) { { "messages" => [{ "role" => "user", :content => "Give me simple js code" }], "model" => "gpt-3.5-turbo", "max_tokens" => 3000, "temperature" => 0.7 } }
      it 'successfully completes request' do
        response = subject.execute_request(correct_payload)
        expect(response).to be_a(Hash)
        expect(response['model']).to eq('gpt-3.5-turbo-0125')
        expect(response['object']).to eq('chat.completion')
        expect(response['choices']).to be_a(Array)
        answer = response['choices'].first
        expect(answer.dig('message', 'content')).to eq("Sure, here is a simple JavaScript code that prints \"Hello, World!\" to the console:\n\n```javascript\nconsole.log(\"Hello, World!\");\n```")
      end
    end
  end
end
