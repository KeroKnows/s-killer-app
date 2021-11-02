# frozen_string_literal: true

# https://github.com/laserlemon/figaro

require 'roda'
require 'yaml'
require 'figaro'

module Skiller
  # Configuration for the App
  class App < Roda
    plugin :environments

    Figaro.application = Figaro::Application.new(
      environment: environment,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load

    # Make the environment variables accessible
    def self.config()
      Figaro.env
    end

    # CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
    # REED_TOKEN = CONFIG['REED_TOKEN']
  end
end
