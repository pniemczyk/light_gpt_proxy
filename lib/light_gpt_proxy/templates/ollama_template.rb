# frozen_string_literal: true

require_relative 'template'

module LightGptProxy
  module Templates
    class OllamaTemplate < LightGptProxy::Template
      def self.required
        []
      end

      def self.optional
        {
          model: 'llama3.2',
          stream: false,
          port: 11_434
        }
      end

      def self.template
        {
          'host' => 'http://localhost:<%= attributes[:port] %>',
          'endpoints' => {
            'chat' => {
              'path' => 'api/chat',
              'method' => 'POST',
              'defaults' => {
                'model' => '<%= attributes[:model] %>',
                'messages' => [
                  {
                    'role' => 'user',
                    'content' => 'why is the sky blue?'
                  }
                ],
                'stream' => '<%= attributes[:stream] %>'
              },
              'body_schema' => {
                'model' => { 'type' => 'string', 'required' => true, 'default' => '<%= attributes[:model] %>' },
                'messages' => {
                  'type' => 'array',
                  'schema' => {
                    'role' => { 'type' => 'string', 'required' => true },
                    'content' => { 'type' => 'string', 'required' => true, 'default' => 'user' }
                  },
                  'default' => [{ 'role' => 'user', 'content' => 'why is the sky blue?' }],
                  'required' => true
                },
                'stream' => { 'type' => 'boolean', 'required' => false, 'default' => false }
              }
            }
          }
        }.freeze
      end
    end
  end
end
