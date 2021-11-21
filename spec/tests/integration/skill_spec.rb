# frozen_string_literal: true

require_relative '../../helpers/vcr_helper'

describe 'Test Skill Analyzer library' do
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_vcr_for_reed(REED_CASSETTE_FILE)
  end

  after do
    Skiller::VcrHelper.eject_vcr
  end

  describe 'Test Extractor' do
    before do
      job_mapper = Skiller::Reed::JobMapper.new(CONFIG)
      @job_list = job_mapper.job_list(TEST_KEYWORD)
      @job = job_mapper.job(@job_list.first.job_id)
    end

    it 'HAPPY: should parse HTML properly' do
      extractor = Skiller::Skill::Extractor.new(@job)
      description = extractor.gen_description
      _(description).wont_match %r{</?\w+>}
    end

    it 'HAPPY: should be able to parse result into an array' do
      extractor = Skiller::Skill::Extractor.new(@job)
      extractor.extract
      skillset = extractor.parse
      _(skillset).must_be_instance_of Array
    end
  end

  describe 'Test SkillMapper' do
    before do
      job_mapper = Skiller::Reed::JobMapper.new(CONFIG)
      @job_list = job_mapper.job_list(TEST_KEYWORD)
      @job = job_mapper.job(@job_list.first.job_id)
    end

    it 'SAD: should check for full job description' do
      _(proc do
        Skiller::Skill::SkillMapper.new(@job_list.first)
      end).must_raise RuntimeError
    end

    it 'HAPPY: should be able to extract skill' do
      skill_mapper = Skiller::Skill::SkillMapper.new(@job)
      _(skill_mapper.skills).wont_be_empty
    end

    it 'HAPPY: skills should have their names' do
      skills = Skiller::Skill::SkillMapper.new(@job).skills
      skills.each { |skill| _(skill).must_respond_to :name }
    end
  end
end
