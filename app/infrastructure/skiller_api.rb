# frozen_string_literal: true

require 'http'

module Skiller
  module Gateway
    # Infrastructure to call Skiller API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      # Ensure our API is alive
      def alive?
        @request.get_root.success?
      end

      # GET result from given query
      def result(query)
        @request.get_result(query)
      end

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = "#{config.API_HOST}/api/v1"
        end

        def get_root # rubocop:disable Naming/AccessorMethodName
          call_api('get')
        end

        def get_result(query)
          call_api('get', ['jobs'], 'query' => query)
        end

        private

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
                .then { |str| str ? "?#{str}" : '' }
        end

        # Send request to our api
        def call_api(method, resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          HTTP.headers('Accept' => 'application/json').send(method, url)
              .then { |http_response| Response.new(http_response) }
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        NotFound = Class.new(StandardError)

        SUCCESS = (200..299)

        def success?
          code.between?(SUCCESS.first, SUCCESS.last)
        end

        def message
          payload['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end
