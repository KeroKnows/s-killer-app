require 'http'
require 'yaml'

config = YAML.safe_load(File.read('../config/secrets.yml'))

job_title = "engineer"
url = "https://www.reed.co.uk/api/1.0/search?keywords=#{job_title}"



response = HTTP.basic_auth(:user => "#{config['API_KEY']}", :pass => "").get(url)
result = response.parse

reed_response = {}
reed_results = {}

reed_response[url] = response
reed_results[url] = result
