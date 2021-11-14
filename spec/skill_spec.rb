# frozen_string_literal: true

require_relative 'helpers/vcr_helper'

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
      extractor = Skiller::SkillAnalyzer::Extractor.new(@job)
      description = extractor.gen_description
      _(description).wont_match %r{</?\w+>}
    end

    it 'HAPPY: should be able to parse result into an array' do
      extractor = Skiller::SkillAnalyzer::Extractor.new(@job)
      extractor.extract
      skillset = extractor.parse
      _(skillset).must_be_instance_of Array
    end
  end
end
