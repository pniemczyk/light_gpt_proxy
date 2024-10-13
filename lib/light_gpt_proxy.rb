# frozen_string_literal: true

require 'yaml'
require 'forwardable'
require 'rack/handler/puma'

require_relative 'light_gpt_proxy/version'
require_relative 'light_gpt_proxy/config'
require_relative 'light_gpt_proxy/provider'
require_relative 'light_gpt_proxy/logger'
require_relative 'light_gpt_proxy/proxy_server'
require_relative 'light_gpt_proxy/templates'
require_relative 'light_gpt_proxy/guard'

module LightGptProxy
  CONFIG_FILE = '.light_gpt_proxy.yml'
  ENCRYPTED_CONFIG_FILE = '.light_gpt_proxy.yml.enc'
  DEFAULT_PORT = 3030
  DEFAULT_CONFIG = { 'default_port' => DEFAULT_PORT, 'verbose' => true, 'default_provider' => nil }.freeze

  Error = Class.new(StandardError)

  class << self
    extend Forwardable

    def_delegators :config, :providers, :default_provider, :default_port
    attr_accessor :passwd, :verb

    def config? = File.exist?(config_path)
    def encrypted_config? = config_path&.end_with?('.enc')

    def config_path
      @config_path ||= [
        File.join(Dir.pwd, CONFIG_FILE),
        File.join(Dir.pwd, ENCRYPTED_CONFIG_FILE),
        File.join(Dir.home, CONFIG_FILE),
        File.join(Dir.home, ENCRYPTED_CONFIG_FILE)
      ].find { |path| File.exist?(path) }
    end

    def config
      @config ||= Config.new(
        if config?
          if encrypted_config?
            raise Error, 'Please provide a password to decrypt the config' unless passwd

            guard(passwd).decode(config_path)
          else
            YAML.load_file(config_path)
          end
        else
          DEFAULT_CONFIG
        end
      )
    end

    def guard(pass = passwd) = Guard.new(pass)
    def provider(name) = config.provider(name)
    def logger = @logger ||= Logger.new($stdout, verbose: verb)
    def server = @server ||= LightGptProxy::ProxyServer

    def start(port: nil, password: passwd, verbose: true)
      @passwd = password
      @verb = verbose
      verify_password! if encrypted_config?
      port ||= config.default_port
      logger.info("Starting LightGPT Proxy server on port #{port} with Puma")
      @server_thread = Thread.new do
        Rack::Handler::Puma.run(server, Port: port)
      end
      @server_thread.join # Keep the server running by joining the thread indefinitely
    rescue => e # rubocop:disable Style/RescueStandardError
      logger.error("Failed to start server: #{e.message}")
    end

    def verify_password!
      config
    end

    def stop
      logger.info('Stopping LightGPT Proxy server')
      if @server_thread
        Thread.kill(@server_thread)
        logger.info('Server stopped successfully')
      else
        logger.warn('Server is not running')
      end
    end
  end
end
