# frozen_string_literal: true

module LightGptProxy
  class Config
    def initialize(data)
      raise ArgumentError, 'Config data must be a Hash' unless data.is_a?(Hash)

      @data = data
    end

    attr_reader :data

    def providers_instances
      @providers_instances ||= {}
    end

    def providers = data['providers']&.keys || []

    def provider(name)
      return providers_instances[name] if providers_instances[name]

      provider_data = data['providers']&.fetch(name, nil)
      raise ArgumentError, "Provider '#{name}' not found" unless provider_data

      providers_instances[name] = Provider.new(name:, config: provider_data)
    end

    private

    def method_missing(symbol, *args)
      key = symbol.to_s
      return data[key] if data.key?(key)

      super
    end

    def respond_to_missing?(symbol, include_private = false)
      key = symbol.to_s
      data.key?(key) || super
    end
  end
end
