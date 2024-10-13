# frozen_string_literal: true

RSpec.describe LightGptProxy do
  subject { described_class }

  let!(:config_path) { File.join(Dir.pwd, 'spec/support/configs/.light_gpt_proxy.yml') }
  before { allow(subject).to receive(:config_path).and_return(config_path.to_s) }

  it 'has a version number' do
    expect(LightGptProxy::VERSION).not_to be nil
  end

  it '#providers returns all providers' do
    expect(subject.providers).to eq(['open_ai'])
  end

  it '#default_provider returns default provider' do
    expect(subject.default_provider).to eq('open_ai')
  end

  it '#default_port returns default port' do
    expect(subject.default_port).to eq(3030)
  end

  it '#verb returns save history' do
    expect(subject.verb).to be_falsey
  end

  it '#provider returns provider instance' do
    expect(subject.provider('open_ai')).to be_a(LightGptProxy::Provider)
  end

  it '#logger returns logger instance' do
    expect(subject.logger).to be_a(LightGptProxy::Logger)
  end

  it '#server returns server instance' do
    expect(subject.server).to eq(LightGptProxy::ProxyServer)
  end

  describe '#start' do
    let(:mock_logger) { instance_double(LightGptProxy::Logger) }
    let(:mock_thread) { instance_double(Thread) }

    before do
      allow(subject).to receive(:logger).and_return(mock_logger)
      allow(mock_logger).to receive(:info)
      allow(mock_thread).to receive(:join)
      allow(Rack::Handler::Puma).to receive(:run)
      allow(Thread).to receive(:new).and_yield.and_return(mock_thread)
    end

    it 'starts the Puma server' do
      expect(mock_logger).to receive(:info).with('Starting LightGPT Proxy server on port 3030 with Puma')
      expect(Rack::Handler::Puma).to receive(:run).with(subject.server, Port: 3030)
      subject.start
    end

    it 'logs an error if server fails to start' do
      allow(Rack::Handler::Puma).to receive(:run).and_raise('Server failed to start')
      expect(mock_logger).to receive(:error).with('Failed to start server: Server failed to start')
      subject.start
    end
  end

  describe '#stop' do
    let(:mock_logger) { instance_double(LightGptProxy::Logger) }
    let(:server_thread) { instance_double(Thread) }

    before do
      allow(subject).to receive(:logger).and_return(mock_logger)
      allow(mock_logger).to receive(:info)
      allow(mock_logger).to receive(:warn)
      allow(Thread).to receive(:new).and_return(server_thread)
    end

    context 'when the server is running' do
      before { subject.instance_variable_set(:@server_thread, server_thread) }

      it 'stops the Puma server' do
        expect(mock_logger).to receive(:info).with('Stopping LightGPT Proxy server')
        expect(mock_logger).to receive(:info).with('Server stopped successfully')
        expect(Thread).to receive(:kill).with(server_thread)
        subject.stop
      end
    end

    context 'when the server is not running' do
      before { subject.instance_variable_set(:@server_thread, nil) }

      it 'logs a warning that the server is not running' do
        expect(mock_logger).to receive(:info).with('Stopping LightGPT Proxy server')
        expect(mock_logger).to receive(:warn).with('Server is not running')
        subject.stop
      end
    end
  end
end
