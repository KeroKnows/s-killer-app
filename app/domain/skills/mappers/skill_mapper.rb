# frozen_string_literal: true

# require_relative '../../../infrastructure/skill_extractor/init'

module Skiller
  module Skill
    # Get an array of `Skill` from an array of Entity::Job, using Skill::Extractor
    class SkillMapper
      def initialize(job)
        raise 'should be a full job' unless job.isfull

        @job = job
        @extractor = Skiller::Skill::Extractor.new(job)
      end

      # Get job_list from Reed::API and make each job a DataMapper class
      def skills
        skills = @extractor.extract.parse
        skills.map { |skill| DataMapper.new(@job, skill).build_entity }
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(job, skill)
          @job = job
          @skill = skill
        end

        def build_entity
          # TODO: should record more information?
          Entity::Skill.new(
            id: nil,
            name: @skill,
            job_db_id: @job.db_id,
            salary: @job.salary
          )
        end
      end
    end
  end
end
