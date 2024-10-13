# frozen_string_literal: true

module LightGptProxy
  class SchemaValidator
    ValidationError = Class.new(StandardError)

    attr_reader :schema, :payload

    def initialize(schema)
      @schema = schema
    end

    def validate!(payload)
      @payload = payload
      errors = validate_schema(schema, payload)
      raise ValidationError, errors.join(', ') if errors.any?

      true
    end

    alias [] validate!

    private

    def validate_schema(schema, payload, parent_key = nil) # rubocop:disable Metrics/AbcSize
      errors = []

      schema.each do |key, definition|
        full_key = parent_key ? "#{parent_key}.#{key}" : key.to_s
        value = payload[key]

        if definition[:required] && value.nil?
          errors << "#{full_key} is required"
          next
        end

        if value.nil?
          next unless definition['default']

          payload[key] = definition['default']
          value = definition['default']
        end

        case definition['type'].to_sym
        when :string
          errors << "#{full_key} must be a String" unless value.is_a?(String)
          validate_options(full_key, value, definition['options'], errors) if definition['options']
        when :integer
          errors << "#{full_key} must be an Integer" unless value.is_a?(Integer)
        when :float
          errors << "#{full_key} must be a Float" unless value.is_a?(Float)
        when :array
          if value.is_a?(Array)
            if definition[:schema]
              value.each_with_index do |item, index|
                errors.concat(validate_schema(definition[:schema], item, "#{full_key}[#{index}]"))
              end
            end
          else
            errors << "#{full_key} must be an Array"
          end
        else
          errors << "#{full_key} has an unsupported type should be #{definition['type']}"
        end
      end

      errors
    end

    def validate_options(key, value, options, errors)
      return if options.include?(value)

      errors << "#{key} must be one of #{options.join(', ')}"
    end
  end
end
