# frozen_string_literal: true

require_relative '../spec_helper'

module Skiller
  module VcrHelper
    def self.setup_vcr
      VCR.configure do |c|
        c.cassette_library_dir = CASSETTES_FOLDER
        c.hook_into :webmock

        c.filter_sensitive_data('<REED_TOKEN>') { CREDENTIALS }
        c.filter_sensitive_data('<REED_TOKEN_ESC>') { CGI.escape(CREDENTIALS) }
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
