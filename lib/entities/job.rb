# frozen_string_literal: true

module Skiller
  # Library for job information
  class Job
    # abstract class
    # Considering there may be multiple job info sources,
    # I abstracted the method, parse_job(job), and implement it in different classes of sources.
    attr_reader :job_id, :title, :description, :location

    def initialize(data)
      parse_job(data)
    end

    private

    def parse_job(_job)
      raise NotImplementedError, 'Implement this method in a child class'
    end
  end

  module Reed
    # Job information of jobs from Reed API
    class ReedJob < Job
      def initialize(data, details_api = nil)
        super(data)
        @details_api = details_api
        @has_full_info = false
      end

      def full_info?
        @has_full_info
      end

      def request_full_info
        details = @details_api.details(job_id)
        @description = details['jobDescription']
        @has_full_info = true
        full_info?
      end

      def parse_job(job)
        @job_id = job['jobId'].to_s
        @title = job['jobTitle']
        @description = job['jobDescription']
        @location = job['locationName']
      end
    end
  end
end
