# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'Test Skill Analyzer library' do
  describe 'Test Extractor' do
    before do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      @job = Skiller::Entity::Job.new(db_id: nil,
                                      job_id: 0,
                                      title: 'JOB TITLE',
                                      description: '<h1>JOB TITLE</h1><p>description with Python SQL</p>',
                                      location: 'LOCATION',
                                      salary: salary,
                                      url: 'URL',
                                      is_full: true)
    end

    it 'HAPPY: should be able to parse HTML' do
      extractor = Skiller::Skill::Extractor.new(@job)
      _(extractor.description).must_be_instance_of String
      _(extractor.description).wont_match %r{</?\w+>}
    end

    it 'HAPPY: should be able to run the python script' do
      extractor = Skiller::Skill::Extractor.new(@job)
      _(proc { extractor.analyze_skills }).must_be_silent
    end

    it 'HAPPY: should return the results as an array' do
      extractor = Skiller::Skill::Extractor.new(@job)
      _(extractor.skills).must_be_instance_of Array
    end
  end

  describe 'Test SkillMapper' do
    it 'SAD: should request for full job description' do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      job = Skiller::Entity::Job.new(db_id: nil,
                                     job_id: 0,
                                     title: 'JOB TITLE',
                                     description: '<h1>JOB TITLE</h1><p>description with Python SQL</p>',
                                     location: 'LOCATION',
                                     salary: salary,
                                     url: 'URL',
                                     is_full: false)
      _(proc do
        Skiller::Skill::SkillMapper.new(job)
      end).must_raise ArgumentError
    end

    it 'HAPPY: should return Skill entities' do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      job = Skiller::Entity::Job.new(db_id: nil,
                                     job_id: 0,
                                     title: 'JOB TITLE',
                                     description: '<h1>JOB TITLE</h1><p>description with Python SQL</p>',
                                     location: 'LOCATION',
                                     salary: salary,
                                     url: 'URL',
                                     is_full: true)
      skill_mapper = Skiller::Skill::SkillMapper.new(job)
      skill_mapper.skills.map do |skill|
        _(skill).must_be_instance_of Skiller::Entity::Skill
      end
    end
  end
end
