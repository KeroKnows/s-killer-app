# frozen_string_literal: true

require 'http'
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

    # incorporate SearchApi and DetailsApi
    class Api
      def initialize(token)
        @reed_token = token
        @search_api = SearchApi.new(token)
        @details_api = DetailsApi.new(token)
      end

      def search(keyword)
        @search_api.search(keyword)
      end

      def details(job_id)
        @details_api.details(job_id)
      end
    end

    # Represents Reed Search API and fetch most of the data from Reed
    class SearchApi
      API_PATH = 'https://www.reed.co.uk/api/1.0/search'

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
                       .get(API_PATH, params: { keywords: keyword })
        HttpResponse.new(response, HTTP_ERROR).parse
      end
    end

    # Represents Reed Details API and fetch details of a job
    class DetailsApi
      API_PATH = 'https://www.reed.co.uk/api/1.0/jobs'

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
                       .get(File.join(API_PATH, job_id))
        HttpResponse.new(response, HTTP_ERROR).parse
      end
    end
  end
end
