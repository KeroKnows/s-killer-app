# frozen_string_literal: true

# require 'minitest/autorun'
require_relative '../../helpers/acceptance_helper'
require_relative 'pages/details_page'

describe 'Details Page Acceptance Tests' do
  include PageObject::PageFactory
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

  index_url = CONFIG.APP_HOST
  # details_url = "http://127.0.0.1:4001/details?query=#{job_title.sub! ' ', '+'}"
  details_url = "#{index_url}/details?query=#{job_title_url}"

  it '(HAPPY) should be able to read job details' do
    # Given: details page
    visit(DetailsPage, using_params: { query: job_title_url }) do |page|
      _(@browser.url).must_match details_url
      # When: user wants to see the details of a job
      # User is able to see the title
      _(page.title_element.present?).must_equal true
      _(page.skill_list_element.present?).must_equal true
      _(page.salary_list_element.present?).must_equal true
      _(page.vacancies_element.present?).must_equal true

      # Skills are properly presented
      skills = page.skills
      required_skills.map do |required_skill|
        _(skills.include?(required_skill)).must_equal true
      end

      # Then: user clicked search for other jobs
      # Other links be tested here in future development
      page.return_to_index
      _(@browser.url).must_match index_url
    end
  end
end
