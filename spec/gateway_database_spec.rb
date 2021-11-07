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
    end

    it 'HAPPY: should be able to save reed jobs data to database' do
      partial_jobs = Skiller::Reed::PartialJobMapper
                     .new(CONFIG)
                     .job_list(TEST_KEYWORD)
      job_mapper = Skiller::Reed::JobMapper.new(CONFIG)
      first_10_jobs = partial_jobs[0...10].map { |pg| job_mapper.job(pg.job_id) }
      rebuilt_jobs = first_10_jobs.map do |job|
        Skiller::Repository::For.entity(job).create(job)
      end

      first_10_jobs.zip(rebuilt_jobs).map do |orig, rebuilt|
        _(orig.job_id).must_equal(rebuilt.job_id)
        _(orig.description).must_equal(rebuilt.description)
        _(orig.title).must_equal(rebuilt.title)
        _(orig.location).must_equal(rebuilt.location)
        _(orig.min_year_salary).must_equal(rebuilt.min_year_salary)
        _(orig.max_year_salary).must_equal(rebuilt.max_year_salary)
        _(orig.currency).must_equal(rebuilt.currency)
        _(orig.url).must_equal(rebuilt.url)
      end
    end
  end
end
