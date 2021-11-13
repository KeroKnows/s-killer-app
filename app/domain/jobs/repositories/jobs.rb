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

      def self.create(entity) # rubocop:disable Metrics/MethodLength
        db_entity = find(entity)
        return db_entity if db_entity

        salary = entity.salary
        db_job = Database::JobOrm.create(
          job_id: entity.job_id,
          job_title: entity.title,
          description: entity.description,
          location: entity.location,
          min_year_salary: salary.year_min,
          max_year_salary: salary.year_max,
          currency: salary.currency,
          url: entity.url
        )

        rebuild_entity(db_job)
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
          url: db_job.url
        )
      end
    end
  end
end
