# frozen_string_literal: true

# http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/Timestamps.html

require 'sequel'

module Skiller
  module Database
    # Object Relational Mapper for Job and PartialJob Entities
    class JobOrm < Sequel::Model(:jobs)
      one_to_many :skills,
                  class: :'Skiller::Database::JobSkillOrm',
                  key: :job_db_id
      # setting the update timestamp when creating
      plugin :timestamps, update_on_create: true
    end
  end
end
