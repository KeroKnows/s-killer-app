# frozen_string_literal: true

require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'
require_relative '../../../spec_helper'

describe 'Integration Test for AnalyzeSkills Service' do
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_vcr_for_reed(GATEWAY_DATABASE_CASSETTE_FILE)
  end

  after do
    Skiller::VcrHelper.eject_vcr
  end

  describe 'Data validation' do
    it 'BAD: should fail empty query' do
      # GIVEN: an empty query

      # WHEN: the service is called

      # THEN: the service should fail
      
    end

    it 'SAD: should fail with invalid request' do
      # GIVEN: an invalid query

      # WHEN: the service is called

      # THEN: the service should fail
      
    end
  end

  describe 'Retrieve and store jobs' do
    before do
      Skiller::DatabaseHelper.wipe_database
    end

    it 'HAPPY: should search query and generate corresponding entities' do
      # GIVEN: a keyword that hasn't been searched
      query_form = Skiller::Forms::Query.new.call(query: TEST_KEYWORD)

      # WHEN: the service is called with the form object
      jobskill = Skiller::Service::AnalyzeSkills.new.call(query_form)

      # THEN: the service should succeed...
      _(jobskill.success?).must_equal true

      # ...and the jobs should have correct details
      rebuilt_jobs = jobskill.value![:jobs]
      job_mapper = Skiller::Reed::JobMapper.new(CONFIG)
      ori_jobs = rebuilt_jobs.map { |job| job_mapper.job(job.job_id) }

      ori_jobs.zip(rebuilt_jobs).map do |orig, rebuilt|
        _(orig.job_id).must_equal rebuilt.job_id
        _(orig.title).must_equal rebuilt.title
        _(orig.location).must_equal rebuilt.location
      end
      # Did not test the description, because not all entities have full description
      # Did not test salary and url, because they may be nil
    end

    it 'HAPPY: should collect jobs from database' do
      # GIVEN: a keyword that has been searched
      query_form = Skiller::Forms::Query.new.call(query: TEST_KEYWORD)
      db_jobs = Skiller::Service::AnalyzeSkills.new.call(query_form)
                                                   .value![:jobs]

      # WHEN: the service is called with the form object
      jobskill = Skiller::Service::AnalyzeSkills.new.call(query_form)

      # THEN: the service should succeed...
      _(jobskill.success?).must_equal true

      # ...and rebuilt the same entities as those from the database
      rebuilt_jobs = jobskill.value![:jobs]

      db_jobs.zip(rebuilt_jobs).map do |db, rebuilt|
        _(db.job_id).must_equal(rebuilt.job_id)
        _(db.title).must_equal(rebuilt.title)
        _(db.description).must_equal(rebuilt.description)
        _(db.location).must_equal(rebuilt.location)
      end
      # Did not test salary and url, because they may be nil
    end

    it 'HAPPY: should calculate salary distribution from a job list' do
      # GIVEN: a keyword
      query_form = Skiller::Forms::Query.new.call(query: TEST_KEYWORD)

      # WHEN: the service is called
      jobskill = Skiller::Service::AnalyzeSkills.new.call(query_form)

      # THEN: the service should succeed...
      _(jobskill.success?).must_equal true
      jobskill = jobskill.value!

      # ...and culculate the salary distribution
      ## get correct salary distribution
      job_mapper = Skiller::Reed::JobMapper.new(CONFIG)
      jobs = jobskill[:jobs].map { |job| job_mapper.job(job.job_id) }
      salaries = jobs.map(&:salary)
      ori_salary = Skiller::Entity::SalaryDistribution.new(salaries)

      ## get rebuilt salary distribution
      rebuilt_salary = jobskill[:salary_dist]

      ## validate
      _(ori_salary.maximum).must_equal rebuilt_salary.maximum
      _(ori_salary.minimum).must_equal rebuilt_salary.minimum
      _(ori_salary.currency).must_equal rebuilt_salary.currency
    end
  end

  describe 'Extract and store skills' do
    before do
      Skiller::DatabaseHelper.wipe_database
    end

    it 'HAPPY: should analyze skills and store result into database' do
      # GIVEN: a keyword that has been searched

      # WHEN: the service is called

      # THEN: the service whould succeed...

      # ...with correct skills extracted

    end

    it 'HAPPY: should collect skills from database' do
      # GIVEN: a keyword that has been searched

      # WHEN: the service is called

      # THEN: the service whould succeed...

      # ...with correct skills rebuilt
      
    end
  end
end
