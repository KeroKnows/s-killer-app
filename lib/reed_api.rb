# frozen_string_literal: true

require 'http'
require_relative 'jobs'

module Skiller
  module Reed
    module Errors
      class NotFound < StandardError; end
      class InvalidToken < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs
      class InvalidJobId < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs
      class InternalError < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs
    end

    # Library for Reed API Handling
    class ReedApi
      SEARCH_API_PATH = 'https://www.reed.co.uk/api/1.0/search'
      DETAILS_API_PATH = 'https://www.reed.co.uk/api/1.0/jobs'

      HTTP_ERROR = {
        400 => Reed::Errors::InvalidJobId,
        401 => Reed::Errors::InvalidToken,
        404 => Reed::Errors::NotFound,
        500 => Reed::Errors::InternalError
      }.freeze

      def initialize(token)
        @reed_token = token
      end

      def job_list(keyword)
        jobs_data = search(keyword)
        jobs_data.map { |job| ReedJobInfo.new(job, self) }
      end

      def search(keyword)
        response = HTTP.basic_auth(user: @reed_token, pass: '')
                       .get(SEARCH_API_PATH, params: { keywords: keyword })
        response = parse_response(response)
        response['results']
      end

      def details(job_id)
        response = HTTP.basic_auth(user: @reed_token, pass: '')
                       .get(File.join(DETAILS_API_PATH, job_id))
        parse_response(response)
      end

      private

      def parse_response(response)
        raise(HTTP_ERROR[response.code]) unless successful?(response)

        response = response.parse
        raise(HTTP_ERROR[500]) unless valid?(response)

        response
      end

      def successful?(result)
        !HTTP_ERROR.keys.include?(result.code)
      end

      def valid?(result)
        !result.include?('errors')
      end
    end
  end
end
