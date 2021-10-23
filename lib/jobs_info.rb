require 'http'
require 'yaml'

config = YAML.safe_load(File.read('../config/secrets.yml'))

def get_searchAPI_url(job_title)
    "https://www.reed.co.uk/api/1.0/search?keywords=#{job_title}"
end

def get_detailsAPI_url(job_id)
    "https://www.reed.co.uk/api/1.0/jobs/#{job_id}"
end

def send_request(config, url)
    HTTP.basic_auth(:user => "#{config['API_KEY']}", :pass => "").get(url)
end

def get_detail_jd(config, job_results, api_response, job)
    job_id = job["jobId"]

    # send request to details api
    details_url = get_detailsAPI_url(job_id)
    api_response[details_url] = send_request(config, details_url)
    details_result = api_response[details_url].parse

    # get needed information
    job_results[job_id] = {
        "jobTitle": job["jobTitle"],
        "jobDescription": details_result["jobDescription"]
    }
end

api_response = {}
job_results = {}

# Happy request
search_url = get_searchAPI_url("engineer")
api_response[search_url] = send_request(config, search_url)
job_list = api_response[search_url].parse['results']

# request only 5 jobs for explore usage
job_list[1..5].map{ |job| get_detail_jd(config, job_results, api_response, job) }

File.write('../spec/fixtures/job_results.yml', job_results.to_yaml)

# Bad request
api_response["no_auth"] = send_request({}, search_url)
