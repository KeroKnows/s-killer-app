# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Reed library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<REED_TOKEN>') { REED_TOKEN }
    c.filter_sensitive_data('<REED_TOKEN_ESC>') { CGI.escape(REED_TOKEN) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'HTTP communication of Reed Search API' do
    it 'HAPPY: should fetch with correct keyword' do
      result = Skiller::Reed::SearchApi.new(REED_TOKEN).search(TEST_KEYWORD)
      _(result).wont_be_empty
    end

    it 'SAD: should raise exception on invalid token' do
      _(proc do
        Skiller::Reed::SearchApi.new('INVALID TOKEN').search(TEST_KEYWORD)
      end).must_raise Skiller::Reed::Errors::InvalidToken
    end
  end

  it 'HAPPY: job list should be PartialJob' do
    jobs = Skiller::Reed::PartialJobMapper.new(CONFIG, Skiller::Reed::Api).job_list(TEST_KEYWORD)
    jobs.each { |job| _(job).must_be_instance_of Skiller::Entity::PartialJob }
  end

  describe 'HTTP communication of Reed Details API' do
    it 'HAPPY: should fetch details with correct job id' do
      jobs = Skiller::Reed::PartialJobMapper.new(CONFIG, Skiller::Reed::Api).job_list(TEST_KEYWORD)
      details = Skiller::Reed::DetailsApi.new(REED_TOKEN).details(jobs.first.id)
      _(details).wont_be_empty
    end

    it 'SAD: should raise exception on invalid job id' do
      _(proc do
        Skiller::Reed::DetailsApi.new(REED_TOKEN).details('INVALID JOB_ID')
      end).must_raise Skiller::Reed::Errors::InvalidJobId
    end
  end

  describe 'JobInfo' do
    before do
      partial_jobs = Skiller::Reed::PartialJobMapper.new(CONFIG, Skiller::Reed::Api).job_list(TEST_KEYWORD)
      @partial_job = partial_jobs.first
      @job = Skiller::Reed::JobMapper.new(CONFIG, Skiller::Reed::Api).job(@partial_job.id)
    end

    it 'HAPPY: should have job ID' do
      _(@job).must_respond_to :id
    end

    it 'HAPPY: should have location' do
      _(@job).must_respond_to :location
    end

    it 'HAPPY: should have title' do
      _(@job).must_respond_to :title
    end

    it 'HAPPY: should have yearly minimum salary' do
      _(@job).must_respond_to :min_year_salary
    end

    it 'HAPPY: should have yearly maximum salary' do
      _(@job).must_respond_to :max_year_salary
    end

    it 'HAPPY: should have currency' do
      _(@job).must_respond_to :currency
    end

    it 'HAPPY: should have url to the job application' do
      _(@job).must_respond_to :url
    end

    it 'HAPPY: JobMapper should generate Job' do
      _(@job).must_be_instance_of Skiller::Entity::Job
    end

    it 'HAPPY: should be able to request full job info' do
      assert_operator @job.description.length, :>=, @partial_job.description.length
    end

    it 'HAPPY: should have description' do
      _(@job).must_respond_to :description
    end
  end
end
