# frozen_string_literal: true

require 'erb'
require 'yaml'

module LightGptProxy
  class Template
    def self.template = raise(NotImplementedError)
    def self.required = raise(NotImplementedError)
    def self.optional = {}.freeze

    def initialize(**params)
      @params = params
      validate_params!
      @attributes = self.class.optional.merge(params)
    end

    attr_reader :params, :attributes

    def save(path:) = File.write(path, to_yaml)
    def to_h = @to_h ||= YAML.safe_load(to_yaml, permitted_classes: [Symbol])
    def to_yaml = @to_yaml ||= ERB.new(self.class.template.to_yaml).result(binding)

    private

    def validate_params!
      missing_keys = self.class.required - params.keys
      raise ArgumentError, "Missing required keys: #{missing_keys.join(', ')}" unless missing_keys.empty?
    end
  end
end
