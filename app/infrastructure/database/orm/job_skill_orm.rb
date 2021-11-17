# frozen_string_literal: true

require 'sequel'

module Skiller
  module Database
    # Object Relational Mapper for Job and Skill Entities
    class JobSkillOrm < Sequel::Model(:jobs_skills)
      many_to_one :job,
                  class: :'Skiller::Database::JobOrm',
                  key: :job_db_id
    end
  end
end
