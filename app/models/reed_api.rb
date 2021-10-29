# frozen_string_literal: true

require 'http'
require_relative 'jobs'
require_relative 'http_response'

module Skiller
  # Library for Reed API Handling
  module Reed
    # Errors for Reed API Handling
    module Errors
      # for HTTP 404 not found
      class NotFound < StandardError; end
      # for HTTP 401 invalid token
      class InvalidToken < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs
      # for HTTP 400 occured when invalid job_id passed to Reed Details API
      class InvalidJobId < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs
      # for HTTP 500
      class InternalError < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs
    end

    # incorporate ReedSearchApi and ReedDetailsApi
    class ReedApi
      def initialize(token)
        @reed_token = token
        @search_api = ReedSearchApi.new(token)
        @details_api = ReedDetailsApi.new(token)
      end

      def job_list(keyword)
        jobs_data = @search_api.search(keyword)
        jobs_data.map { |job| ReedJobInfo.new(job, @details_api) }
      end
    end

    # Represents Reed Search API and fetch most of the data from Reed
    class ReedSearchApi
      SEARCH_API_PATH = 'https://www.reed.co.uk/api/1.0/search'

      HTTP_ERROR = {
        401 => Reed::Errors::InvalidToken,
        404 => Reed::Errors::NotFound,
        500 => Reed::Errors::InternalError
      }.freeze

      def initialize(token)
        @reed_token = token
      end

      def search(keyword)
        response = HTTP.basic_auth(user: @reed_token, pass: '')
                       .get(SEARCH_API_PATH, params: { keywords: keyword })
        response = HttpResponse.new(response, HTTP_ERROR).parse
        response['results']
      end
    end

    # Represents Reed Details API and fetch details of a job
    class ReedDetailsApi
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

      def details(job_id)
        response = HTTP.basic_auth(user: @reed_token, pass: '')
                       .get(File.join(DETAILS_API_PATH, job_id))
        HttpResponse.new(response, HTTP_ERROR).parse
      end
    end
  end
end
