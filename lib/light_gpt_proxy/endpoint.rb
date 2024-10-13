# frozen_string_literal: true

require 'faraday'
require 'json'
require_relative 'schema_defaults_applier'
require_relative 'schema_validator'

module LightGptProxy
  class Endpoint
    ApplyDefaultsError = Class.new(StandardError)
    RequestError = Class.new(StandardError) do |_klass|
      def initialize(response)
        @response = response
        @status = response&.status
        super("Request failed with status #{response.status}: #{response.reason_phrase} => #{response.body}")
      end
      attr_reader :status, :response
    end

    attr_reader :name, :path, :method, :body_schema, :host, :header_options, :key

    def initialize(name:, path:, host:, key:, method: 'get', body_schema: nil, header_options: {})
      @name = name
      @host = host
      @path = path
      @method = method
      @body_schema = body_schema
      @header_options = header_options
      @key = key
    end

    def validate_and_apply_defaults(payload)
      return payload unless body_schema

      payload = JSON.parse(payload) if payload.is_a?(String)
      apply_defaults(payload)
      validator.validate!(payload)
      payload
    end

    def apply_defaults(payload)
      return payload unless body_schema

      defaults.perform(payload)
      ensure_system_presence_if_needed(payload) if name == 'completions'
    rescue StandardError => e
      raise ApplyDefaultsError, e.message
    end

    def execute_request(payload = {})
      connection = Faraday.new(url: "#{host}/#{path}") do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end

      response = case method.upcase
                 when 'POST'
                   connection.post do |req|
                     req.headers = complete_headers
                     req.body = payload
                   end
                 when 'PUT'
                   connection.put do |req|
                     req.headers = complete_headers
                     req.body = payload
                   end
                 when 'PATCH'
                   connection.patch do |req|
                     req.headers = complete_headers
                     req.body = payload
                   end
                 when 'DELETE'
                   connection.delete do |req|
                     req.headers = complete_headers
                   end
                 when 'GET'
                   connection.get do |req|
                     req.headers = complete_headers
                   end
                 else
                   raise ArgumentError, "Unsupported HTTP method: #{method}"
                 end

      handle_response(response)
    end

    private

    def complete_headers
      options = header_options.is_a?(String) ? JSON.parse(header_options) : header_options
      {
        'Authorization' => "Bearer #{key}"
      }.merge(options || {})
    end

    def defaults = @defaults ||= LightGptProxy::SchemaDefaultsApplier.new(body_schema)
    def validator = @validator ||= LightGptProxy::SchemaValidator.new(body_schema)

    def handle_response(response)
      raise RequestError, response unless response.success?

      response.body
    end

    def ensure_system_presence_if_needed(payload)
      payload['messages'] = LightGptProxy::SchemaDefaultsApplier.ensure_system_presence(
        payload['messages'],
        body_schema.dig('messages', 'default')&.first
      )
    end
  end
end
