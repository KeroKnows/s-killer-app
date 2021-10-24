# frozen_string_literal: true

# Exploring reed API
# job_results stores data from API, with jobId as key
# api_response stores responses from API, with url as key

require 'http'
require 'yaml'

config = YAML.safe_load(File.read('../config/secrets.yml'))
api_response = {}
job_results = {}

def get_searchapi_url(job_title)
  "https://www.reed.co.uk/api/1.0/search?keywords=#{job_title}"
end

def get_detailsapi_url(job_id)
  "https://www.reed.co.uk/api/1.0/jobs/#{job_id}"
end

def send_request(config, url)
  HTTP.basic_auth(user: config['REED_TOKEN'].to_s, pass: '').get(url)
end

def get_detail_jd(config, job_results, api_response, job_id)
  # send request to details api
  url = get_detailsapi_url(job_id)
  api_response[url] = send_request(config, url)
  details_result = api_response[url].parse

  # get needed information
  job_results[job_id] = {
    "jobTitle": details_result['jobTitle'],
    "jobDescription": details_result['jobDescription']
  }
end

## Happy request
url = get_searchapi_url('engineer')
api_response[url] = send_request(config, url)
job_list = api_response[url].parse['results']

# request only 5 jobs for explore usage
job_list[1..5].map { |job| get_detail_jd(config, job_results, api_response, job['jobId']) }

# output file
File.write('../spec/fixtures/job_results.yml', job_results.to_yaml)

## Bad request
api_response['no_auth'] = send_request({}, url)
