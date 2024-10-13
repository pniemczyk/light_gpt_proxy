# frozen_string_literal: true

require 'sinatra'
require 'lockbox'

module LightGptProxy
  class ProxyServer < Sinatra::Base
    HELP_MESSAGE = [
      'Endpoints:',
      'GET  /                    # basic info',
      'GET  /:provider           # list of available endpoints',
      'POST /:provider/:endpoint # proxy request to provider'
    ].freeze

    configure do
      set :logger, LightGptProxy::Logger.new($stdout, verbose: true)
    end

    on_start do
      settings.logger.info('Sinatra is up and running')
    end

    on_stop do
      settings.logger.info('Sinatra is shutting down')
    end

    before do
      content_type :json
      settings.logger.info("Received #{request.request_method} request to #{request.path}")
    end

    helpers do
      def logger = settings.logger

      def respond(body = nil, status_code = 200, &block)
        content_type :json
        status status_code
        begin
          body = block.call if block_given?
          logger.info("Responding with status #{status_code}")
          body.to_json
        rescue => e # rubocop:disable Style/RescueStandardError
          error_class = e.class.to_s
          status_code = case error_class
                        when 'ArgumentError' then 404
                        when 'LightGptProxy::Endpoint::RequestError'
                          e.message.include?('401') ? 401 : 500
                        else
                          500
                        end

          respond_with_error(e, status_code)
        end
      end

      def respond_with_error(error, status_code = 500)
        message = error.is_a?(String) ? error : error&.message
        logger.error("Responding with error(#{error.class}): #{message}, status: #{status_code}")
        payload = { source: :proxy_server, error: { message:, type: error.class.name } }
        env['sinatra.not_found'] = payload
        respond(payload, status_code)
      end
    end

    error do
      respond_with_error(env['sinatra.error'].message, 500)
    end

    error ArgumentError do
      respond_with_error(env['sinatra.error'].message, 404)
    end

    not_found do
      content_type :json
      status 404
      payload = env['sinatra.not_found'] || { error: 'Not Found', message: 'The requested resource could not be found.', help: HELP_MESSAGE }
      payload.to_json
    end

    get '/health' do
      respond({ status: :ok })
    end

    get '/' do
      respond(
        {
          status: "LightGptProxy #{LightGptProxy::VERSION} is running",
          providers: LightGptProxy.providers,
          default_provider: LightGptProxy.default_provider,
          help: HELP_MESSAGE
        }
      )
    end

    get '/:provider' do
      respond { LightGptProxy.provider(params[:provider]).index }
    end

    post '/:provider/:endpoint' do
      respond { LightGptProxy.provider(params[:provider]).perform_request(params[:endpoint], request.body.read) }
    end
  end
end
