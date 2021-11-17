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

            jobs = JobCollector.new(App.config).jobs(query)

            skills = []

            jobs.each do |job|
              skills += Skiller::Skill::SkillMapper.new(job).skills
            end

            ## TODO: extract `Skill` from jobs if the query has not been searched

            ## TODO: then use `Repository::JobsSkills.create()` to put them into database

            ## TODO: use `Repository::QueriesJobs.find_skills_by_query()` if the query has been searched
            view 'details', locals: { query: query, jobs: jobs, skills: skills }
          end
        end
      end
    end

    # request jobs using API if the query has not saved to database
    class JobCollector
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

      def request_jobs_and_update_database(query)
        jobs = request_first_10_full_jobs(query).map { |job| Repository::Jobs.create(job) }
        Repository::QueriesJobs.create(query, jobs.map(&:db_id))
        jobs
      end

      def request_first_10_full_jobs(query)
        partial_jobs = @job_mapper.job_list(query)
        partial_jobs[0...10].map { |pj| @job_mapper.job(pj.job_id) }
      end
    end
  end
end
