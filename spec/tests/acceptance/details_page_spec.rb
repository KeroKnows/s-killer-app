# frozen_string_literal: true

require 'webdrivers/chromedriver'
require 'watir'
require 'minitest/autorun'
require_relative '../../spec_helper'


describe 'Details Page Acceptance Tests' do
  before do
    @browser ||= Watir::Browser.new :chrome
  end

  after do
    @browser.close
    # @headless.destroy
  end

  job_title = 'frontend engineer'
  required_skills = %w[TypeScript AWS JavaScript]
  job_title_url = job_title.sub(' ', '+')

  index_url = 'http://127.0.0.1:4001/'
  # details_url = "http://127.0.0.1:4001/details?query=#{job_title.sub! ' ', '+'}"
  details_url = "http://127.0.0.1:4001/details?query=#{job_title_url}"

  it '(HAPPY) should be able to read job details' do
    # Given: details page
    @browser.goto details_url

    # When: user wants to see the details of a job
    # User is able to see the title
    @browser.span(id: 'title').present?
    @browser.ul(id: 'skill_list').present?
    @browser.ul(id: 'salary_list').present?
    @browser.div(id: 'vacancies').present?
    # Skills are properly presented
    skill_list = @browser.ul(id: 'skill_list')
    skills = skill_list.spans(id: 'skill_name').each(&:text)
    required_skills.map { |required_skill| skills.include? required_skill }

    # Then: user clicked search for other jobs
    # Other links be tested here in future development
    @browser.element(tag_name: 'a').click
    _(@browser.url).must_match index_url
  end
end
