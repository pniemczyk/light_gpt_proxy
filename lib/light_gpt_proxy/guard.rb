# frozen_string_literal: true

require 'yaml'
require 'lockbox'
require 'digest'

module LightGptProxy
  class Guard
    class DecryptionError < StandardError; end

    attr_reader :key

    def initialize(key)
      @key = Digest::SHA256.hexdigest(key)
      @lockbox = Lockbox.new(key: @key)
    end

    def encode(data, filepath)
      yaml_content = data.to_yaml
      encrypted_content = @lockbox.encrypt(yaml_content)
      File.write(filepath, encrypted_content)
    end

    def decode(filepath)
      encrypted_content = File.read(filepath)
      begin
        decrypted_content = @lockbox.decrypt(encrypted_content)
        YAML.safe_load(decrypted_content)
      rescue Lockbox::DecryptionError
        raise DecryptionError, 'Failed to decrypt file. Incorrect password or corrupted file.'
      end
    end
  end
end
