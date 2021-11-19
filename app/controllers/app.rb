# frozen_string_literal: true

require 'roda'
require 'slim'

module Skiller
  # Web Application for S-killer
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :halt

    route do |router|
      # GET /
      router.root do
        query = router.params['query']

        view 'index', locals: { query: query }
      end

      # GET /index
      router.on 'index' do
        router.is do
          router.redirect('/')
        end
      end

      router.on 'details' do
        router.is do
          # GET /details?query=[query]
          router.get do
            router.halt 400 unless router.params.include? 'query'

            query = router.params['query']

            collector = DataCollector.new(App.config)
            jobs = collector.jobs(query)
            skills = collector.skillset(query, jobs)

            view 'details', locals: { query: query, jobs: jobs, skills: skills }
          end
        end
      end
    end

    # request jobs using API if the query has not saved to database
    class DataCollector
      def initialize(config)
        @job_mapper = Skiller::Reed::JobMapper.new(config)
      end

      def jobs(query)
        if Repository::QueriesJobs.query_exist?(query)
          Repository::QueriesJobs.find_jobs_by_query(query)
        else
          request_jobs_and_update_database(query)
        end
      end

      def skillset(query, jobs)
        if Repository::QueriesJobs.query_exist?(query)
          skill_list = Repository::QueriesJobs.find_skills_by_query(query)
        else
          # [ TODO ] analyze skillset from more data
          skill_list = jobs[..10].map { |job| extract_skills_and_update_database(job) }
                                 .reduce(:+)
          Repository::QueriesJobs.find_or_create(query, jobs.map(&:db_id))
        end
        skill_count = skill_list.group_by(&:name)
                                .transform_values!(&:length)
        skill_count.sort_by { |_, count| count }.reverse!
      end

      def extract_skills_and_update_database(job)
        if Repository::JobsSkills.job_exist?(job)
          Repository::JobsSkills.find_skills_by_job_id(job.db_id)
        else
          job = request_full_job_and_update_database(job) unless job.is_full
          skills = Skiller::Skill::SkillMapper.new(job).skills
          Repository::JobsSkills.find_or_create(skills)
        end
      end

      def request_jobs_and_update_database(query)
        job_list = @job_mapper.job_list(query)
        job_list.map do |job|
          Repository::Jobs.find_or_create(job)
        end
      end

      def request_full_job_and_update_database(job)
        job = Repository::Jobs.find(job)
        return job if job.is_full

        full_job = @job_mapper.job(job.job_id, job)
        Repository::Jobs.update(full_job)
        Repository::Jobs.find(full_job)
      end
    end
  end
end
