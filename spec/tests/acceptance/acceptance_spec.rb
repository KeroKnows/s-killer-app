require 'webdrivers/chromedriver'
require 'watir'
require "minitest/autorun"
require_relative '../../spec_helper'

describe 'Enter Job Query' do 
  before do
    unless @browser
      # @headless = Headless.new
      @browser = Watir::Browser.new :chrome
    end
  end
  
  after do
    @browser.close
    # @headless.destroy
  end
  
  index_url = 'http://127.0.0.1:4001/'
  valid_request = 'frontend engineer'
  invalid_request = 'asdf'

  it '(HAPPY) should be able to request a job query' do
    # Given: index page
    @browser.goto index_url

    # When: user wants to send a request
    # User is able to locate where to input and send query
    @browser.text_field(name: 'query').present?
    @browser.button(type: 'submit').present?
    # Input a valid request
    @browser.text_field(name: 'query').set(valid_request)
    @browser.button(type: 'submit').click

    # Then: user jumps to the correct details url
    @browser.url.include? valid_request.sub! ' ', '+'
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

    # When: user wants to send a request
    # User is able to locate where to input and send query
    @browser.text_field(name: 'query').present?
    @browser.button(type: 'submit').present?
    # Input a valid request
    @browser.text_field(name: 'query').set('')
    @browser.button(type: 'submit').click

    # Then: user jumps to the correct details url
    _(@browser.url).must_match index_url
  end
end

describe 'View Job Details' do
  before do
    unless @browser
      # @headless = Headless.new
      @browser = Watir::Browser.new :chrome
    end
  end
  
  after do
    @browser.close
    # @headless.destroy
  end
  
  job_title = "frontend engineer"
  required_skills = ["TypeScript", "AWS", "JavaScript"]

  index_url = 'http://127.0.0.1:4001/'
  details_url = "http://127.0.0.1:4001/details?query=#{job_title.sub! ' ', '+'}"

  it '(HAPPY) should be able to read job details' do
    # Given: details page
    @browser.goto details_url

    # When: user wants to see the details of a job
    # User is able to see the title
    @browser.span(id: "title").present?
    @browser.ul(id: "skill_list").present?
    @browser.ul(id: "salary_list").present?
    @browser.div(id: "vacancies").present?
    # Skills are properly presented
    skill_list = @browser.ul(id: "skill_list")
    skills = skill_list.spans(id: "skill_name").each {|skill| skill.text}
    required_skills.map {|required_skill| skills.include? required_skill}

    # Then: user clicked search for other jobs
    # Other links be tested here in future development
    @browser.element(tag_name: 'a').click
    _(@browser.url).must_match index_url
  end
end

describe 'Check Session Warning (Cookies)' do 
  before do
    unless @browser
      # @headless = Headless.new
      @browser = Watir::Browser.new :chrome
    end
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
    @browser.div(id: "flash_bar_success").present?
    _(@browser.div(id: "flash_bar_success").text).must_match valid_query_notice
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
    @browser.div(id: "flash_bar_danger").present?
    _(@browser.div(id: "flash_bar_danger").text).must_match invalid_query_warning
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
    @browser.div(id: "flash_bar_danger").present?
    _(@browser.div(id: "flash_bar_danger").text).must_match empty_query_warning
  end
end
