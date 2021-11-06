# frozen_string_literal: true

module Skiller
  module Repository
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

      def self.create(entity)
        raise 'Job already exists' if find(entity)

        db_job = Database::JobOrm.create(
          job_id: entity.job_id,
          job_title: entity.title,
          description: entity.description,
          location: entity.location,
          min_year_salary: entity.min_year_salary,
          max_year_salary: entity.max_year_salary,
          currency: entity.currency,
          url: entity.url
        )

        rebuild_entity(db_job)
      end

      def self.rebuild_entity(db_job)
        return nil unless db_job

        Entity::Job.new(
          id: db_job.id,
          job_id: db_job.job_id,
          title: db_job.job_title,
          description: db_job.description,
          location: db_job.location,
          min_year_salary: db_job.min_year_salary,
          max_year_salary: db_job.max_year_salary,
          currency: db_job.currency,
          url: db_job.url
        )
      end
    end
  end
end
