require 'http'
require 'yaml'

def get_searchAPI_url(job_title)
    url = "https://www.reed.co.uk/api/1.0/search?keywords=#{job_title}"
end

def get_detailsAPI_url(job_id)
    url = "https://www.reed.co.uk/api/1.0/jobs/#{job_id}"
end

def send_request(url)
    config = YAML.safe_load(File.read('../config/secrets.yml'))
    HTTP.basic_auth(:user => "#{config['API_KEY']}", :pass => "").get(url)
end

reed_search_response = {}
reed_details_response = {}

reed_search_results = {}
reed_details_results = {}

job_results = {}

search_url = get_searchAPI_url("engineer")

reed_search_response[search_url] = send_request(search_url)
job_list = reed_search_response[search_url].parse['results']

for job in job_list[1..10]
    jobID = job["jobId"]

    details_url = get_detailsAPI_url(jobID)
    reed_details_response[details_url] = send_request(details_url)
    reed_details_results[details_url] = reed_details_response[details_url].parse

    job_results[jobID] = {}
    job_results[jobID]["jobTitle"] = job["jobTitle"]
    job_results[jobID]["jobDescription"] = reed_details_results[details_url]["jobDescription"]
end

File.write('../spec/fixtures/job_results.yml', job_results.to_yaml)
