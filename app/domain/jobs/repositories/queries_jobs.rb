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
          JobsSkills.find_skills_by_job(query_job.job_db_id).each { |skill| skills.append(skill) }
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

      def self.create(query, job_db_ids)
        raise 'Query already exists' if query_exist?(query)

        job_db_ids.map do |job_db_id|
          Database::QueryJobOrm.create(query: query, job_db_id: job_db_id)
        end
      end
    end
  end
end
