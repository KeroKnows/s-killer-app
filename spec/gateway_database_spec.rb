# frozen_string_literal: true

require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'
require_relative 'spec_helper'

describe 'Integration Tests of Reed API and Database' do
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_vcr_for_reed(GATEWAY_DATABASE_CASSETTE_FILE)
    Skiller::DatabaseHelper.wipe_database
    job_mapper = Skiller::Reed::JobMapper.new(CONFIG)
    partial_jobs = job_mapper.job_list(TEST_KEYWORD)
    @first_10_jobs = partial_jobs[0...10].map { |pg| job_mapper.job(pg.job_id) }
  end

  after do
    Skiller::VcrHelper.eject_vcr
  end

  describe 'Retrieve and store jobs' do
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
  end

  describe 'Retrieve and store skills' do
    before do
      rebuilt_jobs = @first_10_jobs.map do |job|
        Skiller::Repository::For.entity(job).create(job)
      end
      @job = rebuilt_jobs.first
      @skills = [
        Skiller::Entity::Skill.new(id: nil, job_db_id: @job.db_id, name: 'python', salary: @job.salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: @job.db_id, name: 'java', salary: @job.salary)
      ]
    end

    it 'HAPPY: should be able to save skills data to database' do
      rebuilt_skills = @skills.map do |skill|
        Skiller::Repository::Skills.find_or_create(skill.name)
      end

      @skills.zip(rebuilt_skills).map do |orig, rebuilt|
        _(orig.name).must_equal(rebuilt.name)
      end
    end
  end

  describe 'Retrive and store the mapping between jobs and skills' do
    before do
      rebuilt_jobs = @first_10_jobs.map do |job|
        Skiller::Repository::For.entity(job).create(job)
      end
      @job = rebuilt_jobs.first
      @skills = [
        Skiller::Entity::Skill.new(id: nil, job_db_id: @job.db_id, name: 'python', salary: @job.salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: @job.db_id, name: 'java', salary: @job.salary)
      ]
    end

    it 'HAPPY: should be able to save the mapping between jobs and skills' do
      rebuilt_skills = Skiller::Repository::JobsSkills.find_or_create(@skills)
      @skills.zip(rebuilt_skills).map do |orig, rebuilt|
        _(orig.name).must_equal(rebuilt.name)
        _(orig.job_db_id).must_equal(rebuilt.job_db_id)
        _(orig.salary).must_equal(rebuilt.salary)
      end
    end
  end

  describe 'Retrive and store the mapping between queries and jobs' do
    before do
      @rebuilt_jobs = @first_10_jobs.map do |job|
        Skiller::Repository::For.entity(job).create(job)
      end
      @job = @rebuilt_jobs.first
      @skills = [
        Skiller::Entity::Skill.new(id: nil, job_db_id: @job.db_id, name: 'python', salary: @job.salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: @job.db_id, name: 'java', salary: @job.salary)
      ]
      @rebuilt_skills = Skiller::Repository::JobsSkills.find_or_create(@skills)
      job_db_ids = @rebuilt_jobs.map(&:db_id)
      Skiller::Repository::QueriesJobs.find_or_create(TEST_KEYWORD, job_db_ids)
    end

    it 'HAPPY: should be able to save query and jobs data to database' do
      query_jobs = Skiller::Repository::QueriesJobs.find_jobs_by_query(TEST_KEYWORD)

      query_jobs.zip(@rebuilt_jobs).map do |orig, rebuilt|
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

    it 'HAPPY: sould be able to find skills by a given query' do
      rebuilt_skills = Skiller::Repository::QueriesJobs.find_skills_by_query(TEST_KEYWORD)

      @rebuilt_skills.zip(rebuilt_skills).map do |orig, rebuilt|
        _(orig.name).must_equal(rebuilt.name)
        _(orig.job_db_id).must_equal(rebuilt.job_db_id)
        _(orig.salary).must_equal(rebuilt.salary)
      end
    end
  end
end
