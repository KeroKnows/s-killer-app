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
        if input.success?
          Success(query: input[:query])
        else
          Failure("Invalid query: '#{input[:query]}'")
        end
      end

      # Collect jobs from database if the query has been searched;
      # otherwise, the entites will be created by mappers stored into the database
      def collect_jobs(input)
        query = input[:query]
        if Repository::QueriesJobs.query_exist?(query)
          input[:jobs] = Repository::QueriesJobs.find_jobs_by_query(query)
        else
          input[:jobs] = request_jobs_and_update_database(query)
        end
        input[:jobs].length.zero? ? Failure("No job is found with query #{input[:query]}")
                                  : Success(input)
      rescue StandardError => error
        Failure("Fail to collect jobs: #{error.to_s}")
      end

      # Collect skills from database if the query has been searched;
      # otherwise, the entities will be created by mappers and stored into the database
      def collect_skills(input)
        query = input[:query]
        if Repository::QueriesJobs.query_exist?(query)
          input[:skills] = Repository::QueriesJobs.find_skills_by_query(query)
        else
          input[:skills] = extract_skills_and_update_database(input[:jobs])
        end
        input[:skills].length.zero? ? Failure("No skills are extracted from #{input[:query]}")
                                    : Success(input)
      rescue StandardError => error
        Failure("Fail to extract skills: #{error.to_s}")
      end

      # Analyze the salary distribution from all related jobs
      def calculate_salary_distribution(input)
        all_salary = input[:jobs].map(&:salary)
        input[:salary_dist] = Entity::SalaryDistribution.new(all_salary)
        Success(input)
      rescue StandardError => error
        Failure("Fail to analyze salary distribution: #{error.to_s}")
      end

      # Store the query-job
      # Note that this MUST be executed as the last step,
      #   when the jobs and skills are all correctly extracted,
      #   or the skills of new jobs will not be analyzed forever
      def store_query_to_db(input)
        Repository::QueriesJobs.find_or_create(input[:query], 
                                               input[:jobs].map(&:db_id))
        Success(input)
      rescue StandardError => error
        Failure("Fail to store query result: #{error.to_s}")
      end

      # ------ UTILITIES ------ #

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
