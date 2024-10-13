# frozen_string_literal: true

require_relative 'template'

module LightGptProxy
  module Templates
    class OpenAiTemplate < LightGptProxy::Template
      def self.required
        %i[key]
      end

      def self.optional
        {
          org: nil,
          system: "\nYou are an AI programming assistant.\nFollow the user's requirements carefully & to the letter.\nYour expertise is strictly limited to software development topics.\nKeep your answers short and impersonal.\n\nYou can answer general programming questions and perform the following tasks:\n* Ask a question about the files in your current workspace\n* Explain how the selected code works\n* Generate unit tests for the selected code\n* Propose a fix for the problems in the selected code\n* Scaffold code for a new workspace\n* Create a new Jupyter Notebook\n* Find relevant code to your query\n* Ask questions about VS Code\n* Generate query parameters for workspace search\n* Ask about VS Code extension development\n* Ask how to do something in the terminal\nYou use the GPT-3.5-TURBO version of OpenAI's GPT models.\nFirst think step-by-step - describe your plan for what to build in pseudocode, written out in great detail.\nThen output the code in a single code block.\nMinimize any other prose.\nUse Markdown formatting in your answers.\nMake sure to include the programming language name at the start of the Markdown code blocks.\nAvoid wrapping the whole response in triple backticks.\nYou can only give one reply for each conversation turn." # rubocop:disable Layout/LineLength
        }
      end

      def self.template # rubocop:disable Metrics/MethodLength
        {
          'api_key' => '<%= attributes[:key] %>',
          'header_options' => '<%= attributes[:org] ? {"Content-Type" => "application/json", "OpenAI-Organization": "attributes[:org]"} : {"Content-Type" => "application/json"} %>', # rubocop:disable Layout/LineLength
          'host' => 'https://api.openai.com',
          'endpoints' => {
            'completions' => {
              'path' => 'v1/chat/completions',
              'method' => 'POST',
              'defaults' => {
                'model' => 'gpt-3.5-turbo',
                'messages' => [
                  {
                    'role' => 'system',
                    'content' => '<%= attributes[:system] %>'
                  }
                ],
                'max_tokens' => 2000,
                'temperature' => 0.7
              },
              'body_schema' => {
                'model' => { 'type' => 'string', 'required' => true, 'default' => 'gpt-3.5-turbo', 'options' => ['gpt-4o-mini', 'gpt-4-turbo', 'gpt-3.5-turbo'] },
                'messages' => {
                  'type' =>  'array',
                  'schema' => { 'role' => { 'type' => 'string', 'required' => true },
'content' => { 'type' => 'string', 'required' => true, 'default' => 'user', 'options' => %w[user system assistant] } },
                  'default' => [{ 'role' => 'system', 'content' => '<%= attributes[:system] %>' }],
                  'required' => true
                },
                'max_tokens' => { 'type' => 'integer', 'required' => false, 'default' => 3000 },
                'temperature' => { 'type' => 'float', 'required' => false, 'default' => 0.7 }
              }
            },
            'models' => {
              'path' => 'v1/models',
              'method' => 'GET'
            }
          }
        }.freeze
      end
    end
  end
end
