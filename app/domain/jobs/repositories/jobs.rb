# frozen_string_literal: true

module Skiller
  module Repository
    # Provide the access to jobs table via `JobOrm`
    class Jobs
      def self.all
        Database::JobOrm.all.map { |db_job| rebuild_entity(db_job) }
      end

      def self.find(entity)
        find_db_id(entity.db_id)
      end

      def self.find_db_id(db_id)
        rebuild_entity Database::JobOrm.first(db_id: db_id)
      end

      def self.find_job_id(job_id)
        db_job = Database::JobOrm.first(job_id: job_id)
        rebuild_entity(db_job)
      end

      def self.find_or_create(entity)
        rebuild_entity(Database::JobOrm.find_or_create(entity))
      end

      def self.rebuild_entity(db_job) # rubocop:disable Metrics/MethodLength
        return nil unless db_job

        Entity::Job.new(
          db_id: db_job.db_id,
          job_id: db_job.job_id,
          title: db_job.job_title,
          description: db_job.description,
          location: db_job.location,
          salary: {
            year_min: db_job.min_year_salary,
            year_max: db_job.max_year_salary,
            currency: db_job.currency
          },
          url: db_job.url,
          is_full: db_job.is_full
        )
      end
    end
  end
end
