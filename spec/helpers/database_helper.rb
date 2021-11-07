# frozen_string_literal: true

require_relative '../../config/init'

module Skiller
  # provide spec utility functions of database
  module DatabaseHelper
    def self.wipe_database
      db = Skiller::App.DB
      tables = db.tables
      tables.each { |table| db[table].delete }
    end
  end
end
