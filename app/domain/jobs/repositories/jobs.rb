# frozen_string_literal: true

module Skiller
  module Repository
    # Provide the access to jobs table via `JobOrm`
    class Jobs
      def self.all
        Database::JobOrm.all.map { |db_job| rebuild_entity(db_job) }
      end

      def self.find(entity)
        find_job_id(entity.id)
      end

      def self.find_id(id)
        rebuild_entity Database::JobOrm.first(id: id)
      end

      def self.find_job_id(job_id)
        db_job = Database::JobOrm.first(job_id: job_id)
        rebuild_entity(db_job)
      end

      def self.create(entity) # rubocop:disable Metrics/MethodLength
        raise 'Job already exists' if find(entity)

        db_job = Database::JobOrm.create(
          job_id: entity.job_id,
          job_title: entity.title,
          description: entity.description,
          location: entity.location,
          min_year_salary: entity.salary.year_min,
          max_year_salary: entity.salary.year_max,
          currency: entity.salary.currency,
          url: entity.url
        )

        rebuild_entity(db_job)
      end

      def self.rebuild_entity(db_job) # rubocop:disable Metrics/MethodLength
        return nil unless db_job

        Entity::Job.new(
          id: db_job.id,
          job_id: db_job.job_id,
          title: db_job.job_title,
          description: db_job.description,
          location: db_job.location,
          salary: {
            year_min: db_job.min_year_salary,
            year_max: db_job.max_year_salary,
            currency: db_job.currency,
          },
          url: db_job.url
        )
      end
    end
  end
end
