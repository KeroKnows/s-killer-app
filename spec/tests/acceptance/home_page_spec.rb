# frozen_string_literal: true

require 'webdrivers/chromedriver'
require 'watir'
require 'minitest/autorun'
require_relative '../../spec_helper'

describe 'Homepage Acceptance Tests' do
  before do
    @browser ||= Watir::Browser.new :chrome
  end

  after do
    @browser.close
    # @headless.destroy
  end

  index_url = 'http://127.0.0.1:4001/'
  valid_request = 'frontend engineer'
  invalid_request = 'asdf'
  valid_request_url = valid_request.sub(' ', '+')

  describe 'Visit Home Page' do
    it '(HAPPY) should present an input box and a submit button' do
      # Given: index page
      @browser.goto index_url
  
      # When: user wants to send a request
      # User is able to locate where to input and send query
      @browser.text_field(name: 'query').present?
      @browser.button(type: 'submit').present?
    end

    it '(HAPPY) should be able to request a job query' do
      # Given: index page
      @browser.goto index_url
      
      # Input a valid request
      @browser.text_field(name: 'query').set(valid_request)
      @browser.button(type: 'submit').click
  
      # Then: user jumps to the correct details url
      @browser.url.include? valid_request_url
    end

    it '(BAD) should not be able to request an invalid query' do
      # Given: index page
      @browser.goto index_url
  
      # When: user wants to send an invalid request
      # Input an invalid request
      @browser.text_field(name: 'query').set(invalid_request)
      @browser.button(type: 'submit').click
  
      # Then: user jumps back to index url
      _(@browser.url).must_match index_url
    end

    it '(SAD) should not be able to request blank query' do
      # Given: index page
      @browser.goto index_url
  
      # Input an empty request
      @browser.text_field(name: 'query').set('')
      @browser.button(type: 'submit').click
  
      # Then: user jumps to the correct details url
      _(@browser.url).must_match index_url
    end
  end
end

describe 'Check Session Warning (Cookies)' do
  before do
    @browser ||= Watir::Browser.new :chrome
  end

  after do
    @browser.close
    # @headless.destroy
  end

  index_url = 'http://127.0.0.1:4001/'
  valid_request = 'frontend engineer'
  invalid_request = 'asdf'

  valid_query_notice = "Your last query is '#{valid_request}'"
  invalid_query_warning = "No skills extracted from '#{invalid_request}'"
  empty_query_warning = 'This query is empty'

  it '(HAPPY) should be able to request a job query' do
    # Given: index page
    @browser.goto index_url

    # When: user sends a valid request and returns to index page
    # Input a valid request
    @browser.text_field(name: 'query').set(valid_request)
    @browser.button(type: 'submit').click
    @browser.element(tag_name: 'a').click

    # Then: user sees flash bar
    _(@browser.url).must_match index_url
    @browser.div(id: 'flash_bar_success').present?
    _(@browser.div(id: 'flash_bar_success').text).must_match valid_query_notice
  end

  it '(BAD) should not be able to request an invalid query' do
    # Given: index page
    @browser.goto index_url

    # When: user wants to send an invalid request
    # Input an invalid request
    @browser.text_field(name: 'query').set(invalid_request)
    @browser.button(type: 'submit').click

    # Then: user jumps back to index url
    _(@browser.url).must_match index_url
    @browser.div(id: 'flash_bar_danger').present?
    _(@browser.div(id: 'flash_bar_danger').text).must_match invalid_query_warning
  end

  it '(SAD) should not be able to request an empty query' do
    # Given: index page
    @browser.goto index_url

    # When: user wants to send an empty request
    # Input an invalid request
    @browser.text_field(name: 'query').set('')
    @browser.button(type: 'submit').click

    # Then: user jumps back to index url
    _(@browser.url).must_match index_url
    @browser.div(id: 'flash_bar_danger').present?
    _(@browser.div(id: 'flash_bar_danger').text).must_match empty_query_warning
  end
end
