# frozen_string_literal: true

module Skiller
  module Repository
    class JobsSkills
      def self.find_skills_by_job(job_db_id)
        Database::JobSkillOrm.where(job_db_id: job_db_id).all.map do |job_skill|
          rebuild_entity(job_skill)
        end
      end

      def self.rebuild_entity(job_skill)
        return nil unless job_skill

        job = Jobs.rebuild_entity(job_skill.job)
        Entity::Skill.new(
          id:  job_skill.id,
          name: job_skill.skill,
          job_db_id: job_skill.job_db_id,
          salary: job.salary
        )
      end

    end
  end
end