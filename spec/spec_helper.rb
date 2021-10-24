# frozen_string_literal: true

require 'cgi'
require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'
require 'yaml'

require_relative '../lib/reed_api'

TEST_KEYWORD = 'backend'

CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
REED_TOKEN = CONFIG['REED_TOKEN']

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'reed_api'