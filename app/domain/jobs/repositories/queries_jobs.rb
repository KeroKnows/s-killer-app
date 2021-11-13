module Skiller
  module Repository
    class QueriesJobs
      def self.find_jobs_by_query(query)
        Database::QueryJobOrm.where(query: query).all.map do |query_job|
          Jobs.rebuild_entity(query_job.job)
        end
      end

      def self.query_exist?(query)
        if Database::QueryJobOrm.first(query: query)
          return true
        else
          return false
        end
      end

      def self.create(query, job_db_ids)
        raise 'Query already exists' if query_exist?(query)
        job_db_ids.each do |job_db_id|
          Database::QueryJobOrm.create(query: query, job_db_id: job_db_id)
        end
      end
    end
  end
end