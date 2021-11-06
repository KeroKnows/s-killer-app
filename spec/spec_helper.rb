# frozen_string_literal: true

# Specify we are in test environment as the first thing in our spec setup
ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'cgi'
require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'
require 'yaml'
require 'http'

require_relative '../init'

TEST_KEYWORD = 'backend'

CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
REED_TOKEN = CONFIG['REED_TOKEN']
CREDENTIALS = Base64.strict_encode64("#{REED_TOKEN}:")

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'reed_api'
