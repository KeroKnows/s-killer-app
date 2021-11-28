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
      job_mapper = Skiller::Reed::JobMapper.new(CONFIG)
      job_list = job_mapper.job_list(TEST_KEYWORD)
      first_10_jobs = job_list[..10].map { |job| job_mapper.job(job.job_id) }

      query_form = Skiller::Forms::Query.new.call(TEST_KEYWORD)

      # WHEN: the service is called with the form object
      jobskill = Skiller::Service::AnalyzeSkills.new.call(query_form)

      # THEN: the service should succeed...

      # ...and returns the correct details
      
    end

    it 'HAPPY: should collect jobs from database' do
      # GIVEN: a keyword that has been searched

      # WHEN: the service is called with the form object

      # THEN: the service should succeed...

      # ...and rebuilt the same entities from the database
      
    end

    it 'HAPPY: should calculate salary distribution from a job list' do
      # GIVEN: a keyword

      # WHEN: the service is called

      # THEN: the service should succeed...

      # ...and culculate the salary distribution
      
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
