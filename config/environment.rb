# frozen_string_literal: true

require 'roda'
require 'yaml'

module Skiller
  # Configuration for the App
  class App < Roda
    CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
    REED_TOKEN = CONFIG['REED_TOKEN']
  end
end