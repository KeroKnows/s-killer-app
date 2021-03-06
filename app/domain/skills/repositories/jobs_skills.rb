# frozen_string_literal: true

module Skiller
  module Repository
    # Provide the access to jobs_skills table via `JobSkillOrm`
    class JobsSkills
      def self.find_skills_by_job_id(job_db_id)
        Database::JobSkillOrm.where(job_db_id: job_db_id).all.map do |job_skill|
          rebuild_skill_entity(job_skill)
        end
      end

      def self.rebuild_skill_entity(job_skill)
        return nil unless job_skill

        job = Jobs.rebuild_entity(job_skill.job)
        Skills.rebuild_entity(
          job_skill.skill,
          job.db_id,
          job.salary
        )
      end

      def self.job_exist?(job)
        Database::JobSkillOrm.first(job_db_id: job.db_id) ? true : false
      end

      def self.find_or_create(skills)
        skills.map do |skill|
          db_skill = Database::SkillOrm.find_or_create(skill.name)
          job_skill = Database::JobSkillOrm.find_or_create(skill.job_db_id, db_skill.id)
          rebuild_skill_entity(job_skill)
        end
      end
    end
  end
end
