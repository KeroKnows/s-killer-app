require 'http'
require_relative 'jobs'


module Skiller
  class ReedApi
    SEARCH_API_PATH = 'https://www.reed.co.uk/api/1.0/search'
    DETAILS_API_PATH = 'https://www.reed.co.uk/api/1.0/jobs'

    module Errors
      class NotFound < StandardError; end
      class InvalidToken < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs
      class InternalError < StandardError; end # rubocop:disable Layout/EmptyLineBetweenDefs
    end

    HTTP_ERROR = {
        401 => Errors::InvalidToken,
        404 => Errors::NotFound,
        500 => Errors::InternalError
    }.freeze

    def initialize(token)
      @reed_token = token
    end

    def job_list(keyword)
      jobs_data = search(keyword)
      jobs_data.map { |job| ReedJobInfo.new(job, self) }
    end

    def search(keyword)
      response = HTTP.basic_auth(:user => @reed_token, :pass => '')
                     .get(SEARCH_API_PATH, :params => {:keywords => keyword})
      raise(HTTP_ERROR[response.code]) unless successful?(response)
      response = response.parse
      raise(HTTP_ERROR[500]) unless valid?(response)
      response['results']
    end

    def successful?(result)
      !HTTP_ERROR.keys.include?(result.code)
    end

    def valid?(result)
      !result.include?('errors')
    end
  end
end