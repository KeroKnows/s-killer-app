require 'http'
require 'yaml'

config = YAML.safe_load(File.read('../config/secrets.yml'))

def get_searchAPI_url(job_title)
    url = "https://www.reed.co.uk/api/1.0/search?keywords=#{job_title}"
end

def get_detailsAPI_url(job_id)
    url = "https://www.reed.co.uk/api/1.0/jobs/#{job_id}"
end

def send_request(config, url)
    HTTP.basic_auth(:user => "#{config['API_KEY']}", :pass => "").get(url)
end

api_response = {}
job_results = {}

# Happy request
search_url = get_searchAPI_url("engineer")
api_response[search_url] = send_request(config, search_url)
job_list = api_response[search_url].parse['results']

for job in job_list[1..10]
    jobID = job["jobId"]
    details_url = get_detailsAPI_url(jobID)
    
    api_response[details_url] = send_request(config, details_url)
    details_result = api_response[details_url].parse

    job_results[jobID] = {}
    job_results[jobID]["jobTitle"] = job["jobTitle"]
    job_results[jobID]["jobDescription"] = details_result["jobDescription"]
end

File.write('../spec/fixtures/job_results.yml', job_results.to_yaml)

# Bad request
api_response["no_auth"] = send_request({}, search_url)
