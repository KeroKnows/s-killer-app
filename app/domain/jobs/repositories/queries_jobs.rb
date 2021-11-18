# frozen_string_literal: true

module Skiller
  module Repository
    # Provide the access to queries_jobs table via `QueryJobOrm`
    class QueriesJobs
      def self.find_jobs_by_query(query)
        Database::QueryJobOrm.where(query: query).all.map do |query_job|
          Jobs.rebuild_entity(query_job.job)
        end
      end

      def self.find_skills_by_query(query)
        skills = []
        Database::QueryJobOrm.where(query: query).all.each do |query_job|
          skills += JobsSkills.find_skills_by_job(query_job.job_db_id)
        end
        skills
      end

      def self.query_exist?(query)
        if Database::QueryJobOrm.first(query: query)
          true
        else
          false
        end
      end

      def self.find_or_create(query, job_db_ids)
        job_db_ids.map do |job_db_id|
          Database::QueryJobOrm.find_or_create(query, job_db_id)
        end
      end
    end
  end
end
