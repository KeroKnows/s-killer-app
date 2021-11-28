# frozen_string_literal: true

require 'dry/transaction'

module Skiller
  module Service
    # request the jobs related to given query, and analyze the skillset from it
    class AnalyzeSkills
      include Dry::Transaction

      step :parse_request
      step :collect_jobs
      step :collect_skills
      step :calculate_salary_distribution
      step :store_query_to_db

      private

      # check if the previous form validation passes
      def parse_request(input)
        query = input[:query]
        if input.success?
          Success(query: query)
        else
          Failure("Invalid query: '#{query}'")
        end
      end

      # Collect jobs from database if the query has been searched;
      # otherwise, the entites will be created by mappers stored into the database
      def collect_jobs(input)
        input[:jobs] = search_jobs(input)

        if input[:jobs].length.zero?
          Failure("No job is found with query #{input[:query]}")
        else
          Success(input)
        end
      rescue StandardError => e
        Failure("Fail to collect jobs: #{e}")
      end

      # Collect skills from database if the query has been searched;
      # otherwise, the entities will be created by mappers and stored into the database
      def collect_skills(input)
        input[:skills] = search_skills(input)

        if input[:skills].length.zero?
          Failure("No skills are extracted from #{input[:query]}")
        else
          Success(input)
        end
      rescue StandardError => e
        Failure("Fail to extract skills: #{e}")
      end

      # Analyze the salary distribution from all related jobs
      def calculate_salary_distribution(input)
        all_salary = input[:jobs].map(&:salary)
        input[:salary_dist] = Entity::SalaryDistribution.new(all_salary)
        Success(input)
      rescue StandardError => e
        Failure("Fail to analyze salary distribution: #{e}")
      end

      # Store the query-job
      # Note that this MUST be executed as the last step,
      #   when the jobs and skills are all correctly extracted,
      #   or the skills of new jobs will not be analyzed forever
      def store_query_to_db(input)
        Repository::QueriesJobs.find_or_create(input[:query],
                                               input[:jobs].map(&:db_id))
        Success(input)
      rescue StandardError => e
        Failure("Fail to store query result: #{e}")
      end

      # ------ UTILITIES ------ #

      # search corresponding jobs in database first,
      # or request it through JobMapper
      def search_jobs(input)
        query = input[:query]
        if Repository::QueriesJobs.query_exist?(query)
          Repository::QueriesJobs.find_jobs_by_query(query)
        else
          request_jobs_and_update_database(query)
        end
      end

      # search corresponding skills in database first,
      # or extract it through SkillMapper
      def search_skills(input)
        query = input[:query]
        jobs = input[:jobs]
        if Repository::QueriesJobs.query_exist?(query)
          Repository::QueriesJobs.find_skills_by_query(query)
        else
          extract_skills_and_update_database(jobs)
        end
      end

      # request full job description from API and store into the database
      def request_jobs_and_update_database(query)
        job_mapper = Skiller::Reed::JobMapper.new(App.config)
        jobs = job_mapper.job_list(query)
        # [ TODO ] analyze skillset from more data
        jobs[..10].map do |job|
          full_job = job_mapper.job(job.job_id)
          Repository::Jobs.find_or_create(full_job)
        end
      end

      # analyze the jobs' required skills from mapper and store into the database
      def extract_skills_and_update_database(jobs)
        skill_list = jobs.map do |job|
          if Repository::JobsSkills.job_exist?(job)
            Repository::JobsSkills.find_skills_by_job_id(job.db_id)
          else
            skills = Skiller::Skill::SkillMapper.new(job).skills
            Repository::JobsSkills.find_or_create(skills)
          end
        end
        skill_list.reduce(:+)
      end
    end
  end
end
