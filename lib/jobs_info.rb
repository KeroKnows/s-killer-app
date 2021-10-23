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

url = get_searchAPI_url("engineer")

reed_search_response[url] = send_request(url)
reed_search_results[url] = reed_search_response[url].parse

puts reed_search_results[url]['results'][0]

url = get_detailsAPI_url("44413283")
reed_details_response[url] = send_request(url)
reed_details_results[url] = reed_details_response[url].parse

puts reed_details_results[url]["jobDescription"]