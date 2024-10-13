# frozen_string_literal: true

module LightGptProxy
  class SchemaDefaultsApplier
    attr_reader :schema, :payload

    def initialize(schema)
      @schema = schema
    end

    def perform(payload)
      @payload = payload
      fill_defaults_recursive(schema, payload)
      payload
    end

    alias [] perform

    # helper method to ensure that the system message is present in the messages array only for completions endpoint
    def self.ensure_system_presence(messages, defaults)
      raise TypeError, "messages cannot be #{messages.class.name}" unless messages.is_a?(Array)
      return messages if defaults.nil?
      raise TypeError, "defaults cannot be #{defaults.class.name}" unless defaults.is_a?(Hash)

      return messages if messages.any? { |message| message['role'] == 'system' }

      messages.unshift(defaults)
    end

    private

    def fill_defaults_recursive(schema, payload)
      schema.each do |key, definition|
        value = payload[key]

        if value.nil? && definition['default']
          payload[key] = definition['default']
          value = definition['default']
        end

        next unless definition['type'] == 'array' && definition['schema'] && value.is_a?(Array)

        value.each do |item|
          fill_defaults_recursive(definition['schema'], item)
        end
      end
    end
  end
end
