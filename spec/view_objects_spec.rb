# frozen_string_literal: true

require_relative 'helpers/vcr_helper'

describe 'Test View Objects' do
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_vcr_for_reed(REED_CASSETTE_FILE)
  end

  after do
    Skiller::VcrHelper.eject_vcr
  end

  describe 'Test Job Object' do
    before do
      job_mapper = Skiller::Reed::JobMapper.new(CONFIG)
      job_list = job_mapper.job_list(TEST_KEYWORD)
      @job = job_mapper.job(job_list.first.job_id)
      @job_object = Views::Job.new(@job)
    end

    it 'HAPPY: should extract properties properly' do
      _(@job_object.title).must_equal @job.title
      _(@job_object.location).must_equal @job.location
    end

    it 'HAPPY: should parse description to pure text' do
      _(@job_object.description).wont_match %r{</?\w+>}
    end

    it 'HAPPY: should be able to provide the brief description' do
      _(@job_object.brief.length).must_be :<, 305
    end
  end

  describe 'Test Skill Object' do
    it 'HAPPY: should extract properties properly' do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: 'USD')
      skill = Skiller::Entity::Skill.new(id: nil, 
                                         job_db_id: nil, 
                                         name: 'Python', 
                                         salary: salary)
      count = 10
      skill_object = Views::Skill.new(skill, count)
      _(skill_object.name).must_equal skill.name
      _(skill_object.count).must_equal count
    end

    it 'HAPPY: should not return nil with salary' do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      skill = Skiller::Entity::Skill.new(id: nil, 
                                         job_db_id: nil, 
                                         name: 'Python', 
                                         salary: salary)
      skill_object = Views::Skill.new(skill, 0)
      _(skill_object.min_salary).wont_be_nil
      _(skill_object.max_salary).wont_be_nil
    end

    it 'HAPPY: should transform salary to string' do
      skip 'NOT IMPLEMENTED'

      currency = 'USD'
      min_salary = 10.0
      max_salary = 10000.0
      salary = Skiller::Value::Salary.new(year_min: min_salary, 
                                          year_max: max_salary, 
                                          currency: currency)
      skill = Skiller::Entity::Skill.new(id: nil, 
                                         job_db_id: nil, 
                                         name: 'Python', 
                                         salary: salary)
      _(@skill_object.min_salary_str).must_be "#{currency}$ #{min_salary}"
      _(@skill_object.max_salary_str).must_be "#{currency}$ #{max_salary}"
    end

    it 'HAPPY: should return the relating jobs' do
      skip 'NOT IMPLEMENTED'
    end
  end

  describe 'Test SkillJob Object' do
    it 'HAPPY: should extract the skillset as skill object' do
    end

    it 'HAPPY: should sort the skillset by count' do
    end

    it 'HAPPY: should return the job object' do
    end

    it 'HAPPY: should calculate the max/min salary' do
    end
  end
end
