# frozen_string_literal: true

require 'sequel'

module Skiller
  module Database
    # Object Relational Mapper for Job and Skill Entities
    class SkillOrm < Sequel::Model(:skills)
      one_to_many :jobs,
                  class: :'Skiller::Database::JobSkillOrm',
                  key: :skill_id
            
      def self.find_or_create(skill_name)
        first(name: skill_name) || create(name: skill_name)
      end
    end
  end
end
