# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/reed_api'

KEYWORD = 'backend'
CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
REED_TOKEN = CONFIG['REED_TOKEN']

describe 'Test Reed library' do
  describe 'HTTP communication of Reed Search API' do
    it 'HAPPY: should fetch with correct keyword' do
      result = Skiller::Reed::ReedSearchApi.new(REED_TOKEN).search(KEYWORD)
      _(result).wont_be_empty
    end

    it 'SAD: should raise exception on invalid token' do
      _(proc do
        Skiller::Reed::ReedSearchApi.new('INVALID TOKEN').search(KEYWORD)
      end).must_raise Skiller::Reed::Errors::InvalidToken
    end
  end

  it 'HAPPY: job list should be JobInfo' do
    jobs = Skiller::Reed::ReedApi.new(REED_TOKEN).job_list(KEYWORD)
    jobs.each { |job| _(job).must_be_instance_of Skiller::Reed::ReedJobInfo }
  end

  describe 'HTTP communication of Reed Details API' do
    it 'HAPPY: should fetch details with correct job_id' do
      jobs = Skiller::Reed::ReedApi.new(REED_TOKEN).job_list(KEYWORD)
      details = Skiller::Reed::ReedDetailsApi.new(REED_TOKEN).details(jobs.first.job_id)
      _(details).wont_be_empty
    end

    it 'SAD: should raise exception on invalid job_id' do
      _(proc do
        Skiller::Reed::ReedDetailsApi.new(REED_TOKEN).details('INVALID JOB_ID')
      end).must_raise Skiller::Reed::Errors::InvalidJobId
    end
  end

  describe 'JobInfo' do
    before do
      @jobs = Skiller::Reed::ReedApi.new(REED_TOKEN).job_list(KEYWORD)
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
      _(@job.full_info?).must_equal true
    end

    it 'HAPPY: should have description' do
      _(@job).must_respond_to :description
    end
  end
end
