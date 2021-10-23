# frozen_string_literal: true

module Skiller
  # Library for job information
  class JobInfo
    # abstract class
    # Considering there may be multiple job info sources,
    # I abstracted the method, parse_job(job), and implement it in different classes of sources.
    def initialize(data)
      @data = parse_job(data)
    end

    def job_id
      @data['job_id']
    end

    def title
      @data['title']
    end

    def description
      @data['description']
    end

    def location
      @data['location']
    end

    private

    def parse_job(_job)
      raise NotImplementedError, 'Implement this method in a child class'
    end
  end

  # Job information of jobs from Reed API
  class ReedJobInfo < JobInfo
    def initialize(data, api = nil)
      super(data)
      @api = api
      @has_full_info = false
    end

    def full_info?
      @has_full_info
    end

    def request_full_info
      details = @api.details(job_id)
      @data['description'] = details['jobDescription']
      @has_full_info = true
      full_info?
    end

    def parse_job(job)
      {
        'job_id' => job['jobId'].to_s,
        'title' => job['jobTitle'],
        'description' => job['jobDescription'],
        'location' => job['locationName']
      }
    end
  end
end
