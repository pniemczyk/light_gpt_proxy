# frozen_string_literal: true

require_relative 'endpoint'

module LightGptProxy
  class Provider
    attr_reader :name, :endpoints, :logger

    def initialize(name:, config:)
      @name = name
      @host = config['host']
      @key = config['api_key']
      @global_header_options = config['header_options'] || {}
      @endpoints = build_endpoints(config)
    end

    def perform_request(endpoint_name, payload = {})
      endpoint = find_endpoint(endpoint_name)
      raise ArgumentError, "Endpoint '#{endpoint_name}' not found" unless endpoint

      validated_payload = endpoint.validate_and_apply_defaults(payload) if endpoint.body_schema
      endpoint.execute_request(validated_payload || payload)
    end

    def index
      @endpoints.map do |endpoint|
        {
          name: endpoint.name,
          method: endpoint.method,
          path: endpoint.path,
          schema: endpoint.body_schema
        }
      end
    end

    def find_endpoint(name) = endpoints.find { |ep| ep.name == name.to_s }

    private

    def build_endpoints(config)
      config.fetch('endpoints', {}).map do |name, endpoint_config|
        LightGptProxy::Endpoint.new(
          name:,
          host: @host,
          path: endpoint_config['path'],
          method: endpoint_config['method'],
          body_schema: endpoint_config['body_schema'],
          header_options: endpoint_config.fetch('header_options', @global_header_options),
          key: @key
        )
      end
    end
  end
end
