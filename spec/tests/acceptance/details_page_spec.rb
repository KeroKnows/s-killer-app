# frozen_string_literal: true

require_relative '../../helpers/acceptance_helper'

require_relative 'pages/index_page'
require_relative 'pages/details_page'

describe 'Details Page Acceptance Tests' do
  include PageObject::PageFactory

  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_integration
    @browser ||= Watir::Browser.new :chrome, headless: true
  end

  after do
    @browser.close
    Skiller::VcrHelper.eject_vcr
  end

  index_url = CONFIG.APP_HOST
  details_url = "#{CONFIG.APP_HOST}/details"

  it '(HAPPY) should be able to read job details' do
    # GIVEN: user searches a query
    visit(IndexPage) do |page|
      page.query_job(TEST_KEYWORD)
    end

    # WHEN: jumping to the detail page
    on_page(DetailsPage) do |page|
      # THEN: the url should be correct...
      _(@browser.url).must_match details_url

      # ...and all elements should be shown properly
      _(page.title_element.present?).must_equal true
      _(page.skill_list_element.present?).must_equal true
      _(page.salary_list_element.present?).must_equal true
      _(page.vacancies_element.present?).must_equal true
      _(page.skills.length).wont_equal 0

      # THEN: user clicked search for other jobs
      # Other links be tested here in future development
      page.return_to_index
      _(@browser.url).must_match index_url
    end
  end

  it '(HAPPY) should be able to return home' do
    # GIVEN: user is on the detail page
    visit(IndexPage) do |page|
      page.query_job(TEST_KEYWORD)
    end

    on_page(DetailsPage) do |page|
      # WHEN: user try to return to index page
      page.return_to_index

      # THEN: index page should show
      _(@browser.url).must_match index_url
    end
  end
end
