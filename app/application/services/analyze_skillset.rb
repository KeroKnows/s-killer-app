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
      # step :analyze_skillset

      private

      # check if the previous form validation passes
      def parse_request(input)
        puts 'step 1'
        if input.success?
          Success(query: input[:query])
        else
          Failure('Invalid query format')
        end
      end

      # Collect jobs from database if the query has been searched;
      # otherwise, the entites will be created by mappers stored into the database
      def collect_jobs(input)
        puts 'step 2'
        query = input[:query]
        if Repository::QueriesJobs.query_exist?(query)
          input[:jobs] = Repository::QueriesJobs.find_jobs_by_query(query)
        else
          input[:jobs] = request_jobs_and_update_database(query)
        end
        Success(input)
      rescue StandardError => error
        Failure(error.to_s)
      end

      # Collect skills from database if the query has been searched;
      # otherwise, the entities will be created by mappers and stored into the database
      def collect_skills(input)
        puts 'step 3'
        query = input[:query]
        if Repository::QueriesJobs.query_exist?(query)
          input[:skills] = Repository::QueriesJobs.find_skills_by_query(query)
        else
          input[:skills] = extract_skills_and_update_database(input[:jobs])
        end
        Success(input)
      rescue StandardError => error
        Failure(error.to_s)
      end

      # Analyze the salary distribution from all related jobs
      def calculate_salary_distribution(input)
        puts 'step 4'
        all_salary = input[:jobs].map(&:salary)
        input[:salary_dist] = Entity::SalaryDistribution.new(all_salary)
        Success(input)
      rescue StandardError => error
        Failure(error.to_s)
      end

      # def analyze_skillset(input)
      #   skill_list = input[:skills]
      #   skill_count = skill_list.group_by(&:name).transform_values(&:length)
      #   skill_count.sort_by { |_, count| count }
      #              .reverse!
      #   sorted_skill.map do |name, count|
      #     first_skill = skill_list.find { |skill| skill.name == name }
      #     Views::Skill.new(first_skill, count)
      #   end
      # rescue StandardError => error
      #   Failure(error.to_s)
      # end

      # ------ UTILITIES ------ #

      # request full job description from API and store into the database
      def request_jobs_and_update_database(query)
        job_mapper = Skiller::Reed::JobMapper.new(App.config)
        jobs = job_mapper.job_list(query)
        # [ TODO ] analyze skillset from more data
        jobs = jobs[..10].map do |job|
          full_job = job_mapper.job(job.job_id)
          Repository::Jobs.find_or_create(full_job)
        end
        Repository::QueriesJobs.find_or_create(query, jobs.map(&:db_id))
        jobs
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
