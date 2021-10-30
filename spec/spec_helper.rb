# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'cgi'
require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'
require 'yaml'

require_relative '../init'

TEST_KEYWORD = 'backend'

CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
REED_TOKEN = CONFIG['REED_TOKEN']

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'reed_api'
