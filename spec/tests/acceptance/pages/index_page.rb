# frozen_string_literal: true

# Page object for index page
class IndexPage
  include PageObject

  page_url Skiller::App.config.APP_HOST

  div(:warning_message, id: 'flash_bar_danger')
  div(:success_message, id: 'flash_bar_success')

  text_field(:query, name: 'query')
  button(:submit, type: 'submit')

  def query_job(job_title)
    self.query = job_title
    self.submit
  end
end