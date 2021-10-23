# frozen_string_literal: true

require 'http'
require_relative 'jobs'
require_relative 'http_response'

module Skiller
  # Library for Reed API Handling
  module Reed
    # Errors for Reed API Handling
    module Errors
      class NotFound < StandardError; end
      class InvalidToken < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs
      class InvalidJobId < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs
      class InternalError < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs
    end

    # Represents Reed API and fetch most of the data from Reed
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
        response = HttpResponse.new(response, HTTP_ERROR).parse
        response['results']
      end

      def details(job_id)
        response = HTTP.basic_auth(user: @reed_token, pass: '')
                       .get(File.join(DETAILS_API_PATH, job_id))
        HttpResponse.new(response, HTTP_ERROR).parse
      end
    end
  end
end
