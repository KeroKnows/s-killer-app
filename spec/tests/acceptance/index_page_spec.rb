# frozen_string_literal: true

# require 'minitest/autorun'
require_relative '../../helpers/acceptance_helper'
require_relative 'pages/index_page'

describe 'Indexpage Acceptance Tests' do
  include PageObject::PageFactory

  before do
    @browser ||= Watir::Browser.new :chrome, headless: true
  end

  after do
    @browser.close
  end

  index_url = CONFIG.APP_HOST
  valid_request = 'frontend engineer'
  invalid_request = 'asdf'
  valid_request_url = valid_request.sub(' ', '+')

  valid_query_notice = "Your last query is '#{valid_request}'"
  empty_query_warning = 'invalid query'
  empty_job_warning = 'no job is found'

  describe 'Visit Index Page' do
    it '(HAPPY) should present an input box and a submit button' do
      # Given: index page
      visit IndexPage do |page|
        # When: user wants to send a request
        # User is able to locate where to input and send query
        _(page.query_element.present?).must_equal true
        _(page.button_element.present?).must_equal true
      end
    end

    it '(HAPPY) should be able to request a job query' do
      # Given: index page
      visit IndexPage do |page|
        # Input a valid request
        page.query_job(valid_request)

        # Then: user jumps to the correct details url
        @browser.url.include? valid_request_url

        # Then: user returns to index page
        @browser.element(tag_name: 'a').click

        # Then: user sees flash bar
        _(page.success_message_element.present?).must_equal true
        _(page.success_message_element.text).must_match valid_query_notice
      end
    end

    it '(BAD) should not be able to request an invalid query' do
      # Given: index page
      visit IndexPage do |page|
        # When: user wants to send an invalid request
        # Input an invalid request
        page.query_job(invalid_request)

        # Then: user jumps back to index url
        _(@browser.url).must_match index_url

        # Then: user sees flash bar
        _(page.warning_message_element.present?).must_equal true
        _(page.warning_message_element.text.downcase).must_include empty_job_warning
      end
    end

    it '(SAD) should not be able to request blank query' do
      # Given: index page
      visit IndexPage do |page|
        # Input an empty request
        page.query_job('')

        # Then: user jumps back to index url
        _(@browser.url).must_match index_url

        # Then: user sees flash bar
        _(page.warning_message_element.present?).must_equal true
        _(page.warning_message_element.text.downcase).must_match empty_query_warning
      end
    end
  end
end
