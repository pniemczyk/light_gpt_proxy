# frozen_string_literal: true

module LightGptProxy
  class Logger
    def initialize(io, verbose:)
      @io = io
      @verbose = verbose
    end

    attr_reader :verbose, :io

    def info(message, opts = {})
      log('INFO', message, opts)
    end

    def warn(message, opts = {})
      log('WARN', message, opts)
    end

    def error(message, opts = {})
      log('ERROR', message, opts)
    end

    private

    def log(level, message, opts = {})
      source = opts[:source]
      @io.puts "#{timestamp}: [#{level}] #{source ? "<#{source}>" : ''} #{message}"
    end

    def timestamp
      Time.now.strftime('%Y-%m-%d %H:%M:%S')
    end
  end
end
