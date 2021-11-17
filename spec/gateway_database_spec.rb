# frozen_string_literal: true

require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'
require_relative 'spec_helper'

describe 'Integration Tests of Reed API and Database' do
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_vcr_for_reed(GATEWAY_DATABASE_CASSETTE_FILE)
  end

  after do
    Skiller::VcrHelper.eject_vcr
  end

  describe 'Retrieve and store jobs' do
    before do
      Skiller::DatabaseHelper.wipe_database
      job_mapper = Skiller::Reed::JobMapper.new(CONFIG)
      partial_jobs = job_mapper.job_list(TEST_KEYWORD)
      @first_10_jobs = partial_jobs[0...10].map { |pg| job_mapper.job(pg.job_id) }
    end

    it 'HAPPY: should be able to save reed jobs data to database' do
      rebuilt_jobs = @first_10_jobs.map do |job|
        Skiller::Repository::For.entity(job).create(job)
      end

      @first_10_jobs.zip(rebuilt_jobs).map do |orig, rebuilt|
        _(orig.job_id).must_equal(rebuilt.job_id)
        _(orig.description).must_equal(rebuilt.description)
        _(orig.title).must_equal(rebuilt.title)
        _(orig.location).must_equal(rebuilt.location)
        _(orig.salary.year_min).must_equal(rebuilt.salary.year_min)
        _(orig.salary.year_max).must_equal(rebuilt.salary.year_max)
        _(orig.salary.currency).must_equal(rebuilt.salary.currency)
        _(orig.url).must_equal(rebuilt.url)
      end
    end

    it 'HAPPY: should be able to save query and jobs data to database' do
      rebuilt_jobs = @first_10_jobs.map do |job|
        Skiller::Repository::For.entity(job).create(job)
      end

      job_db_ids = rebuilt_jobs.map(&:db_id)
      Skiller::Repository::QueriesJobs.create(TEST_KEYWORD, job_db_ids)
      query_jobs = Skiller::Repository::QueriesJobs.find_jobs_by_query(TEST_KEYWORD)

      query_jobs.zip(rebuilt_jobs).map do |orig, rebuilt|
        _(orig.job_id).must_equal(rebuilt.job_id)
        _(orig.description).must_equal(rebuilt.description)
        _(orig.title).must_equal(rebuilt.title)
        _(orig.location).must_equal(rebuilt.location)
        _(orig.salary.year_min).must_equal(rebuilt.salary.year_min)
        _(orig.salary.year_max).must_equal(rebuilt.salary.year_max)
        _(orig.salary.currency).must_equal(rebuilt.salary.currency)
        _(orig.url).must_equal(rebuilt.url)
        _(orig.is_full).must_equal(rebuilt.is_full)
      end
    end
  end
end
