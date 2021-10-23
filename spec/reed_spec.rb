# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/reed_api'


KEYWORD = 'backend'
REED_TOKEN = YAML.safe_load(File.read('config/secrets.yml'))


describe 'Test ReedApi library' do
  describe 'HTTP communication' do
    it 'HAPPY: should fetch with correct keyword' do
      result = Skiller::ReedApi.new(REED_TOKEN).search(KEYWORD)
      _(result).wont_be_empty
    end

    it 'HAPPY: job list should be JobInfo' do
      jobs = Skiller::ReedApi.new(REED_TOKEN).job_list(KEYWORD)
      jobs.each { |job| _(job).must_be_instance_of Skiller::ReedJobInfo }
    end

    it 'SAD: should raise exception on invalid token' do
      _(proc do
        Skiller::ReedApi.new("INVALID TOKEN").search(KEYWORD)
      end).must_raise Skiller::ReedApi::Errors::InvalidToken
    end

    it 'HAPPY: should fetch details with correct job_id' do
      reed_api = Skiller::ReedApi.new(REED_TOKEN)
      jobs = reed_api.job_list(KEYWORD)
      details = reed_api.details(jobs.first.job_id)
      _(details).wont_be_empty
    end

    it 'SAD: should raise exception on invalid job_id' do
      _(proc do
        Skiller::ReedApi.new(REED_TOKEN).details("INVALID JOB_ID")
      end).must_raise Skiller::ReedApi::Errors::InvalidJobId
    end

  end

  describe 'JobInfo' do
    before do
      @jobs = Skiller::ReedApi.new(REED_TOKEN).job_list(KEYWORD)
      @job = @jobs.first
    end

    it 'HAPPY: should have job ID' do
      _(@job).must_respond_to :job_id
    end

    it 'HAPPY: should have location' do
      _(@job).must_respond_to :location
    end
    
    it 'HAPPY: should have title' do
      _(@job).must_respond_to :title
    end

    it 'HAPPY: should be able to request full job info' do
      @job.request_full_info
      _(@job.has_full_info?).must_equal true
    end

    it 'HAPPY: should have description' do
      _(@job).must_respond_to :description
    end
  end
end