# frozen_string_literal: true

module LightGptProxy
  module Helpers
    module HashDeepStringifyHelper
      def self.perform(hash)
        result = {}

        hash.each do |key, value|
          new_key = key.to_s
          new_value = case value
                      when Hash
                        perform(value)
                      when Array
                        value.map { |element| element.is_a?(Hash) ? perform(element) : element }
                      else
                        value
                      end
          result[new_key] = new_value
        end

        result
      end
    end
  end
end
