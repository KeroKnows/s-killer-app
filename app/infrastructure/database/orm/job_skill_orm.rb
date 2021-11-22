# frozen_string_literal: true

require 'sequel'

module Skiller
  module Database
    # Object Relational Mapper for Job and Skill Entities
    class JobSkillOrm < Sequel::Model(:jobs_skills)
      many_to_one :job,
                  class: :'Skiller::Database::JobOrm',
                  key: :job_db_id

      many_to_one :skill,
                  class: :'Skiller::Database::SkillOrm',
                  key: :skill_id

      def self.find_or_create(job_db_id, skill_id)
        first(job_db_id: job_db_id, skill_id: skill_id) || create(job_db_id: job_db_id, skill_id: skill_id)
      end
    end
  end
end
