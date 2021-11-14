# frozen_string_literal: true

require_relative '../spec_helper'

module Skiller
  # provide spec utility functions of VCR
  module VcrHelper
    # :reek:TooManyStatements
    def self.setup_vcr
      VCR.configure do |config|
        config.cassette_library_dir = CASSETTES_FOLDER
        config.hook_into :webmock

        config.filter_sensitive_data('<REED_TOKEN>') { CREDENTIALS }
        config.filter_sensitive_data('<REED_TOKEN_ESC>') { CGI.escape(CREDENTIALS) }

        config.filter_sensitive_data('<FREECURRENCY_API_KEY>') { FREECURRENCY_API_KEY }
        config.filter_sensitive_data('<FREECURRENCY_API_KEY_ESC>') { CGI.escape(FREECURRENCY_API_KEY) }
      end
    end

    def self.configure_vcr_for_reed(cassette_file)
      VCR.insert_cassette cassette_file,
                          record: :new_episodes,
                          match_requests_on: %i[method uri headers]
    end

    def self.eject_vcr
      VCR.eject_cassette
    end
  end
end
