# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

require_relative '../../presentation/view_objects/skilljob'

module Skiller
  # Web Application for S-killer
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :halt
    plugin :flash

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

      # GET /details
      router.on 'details' do
        router.is do #no condition, may be duplicate?
          router.post do
            query_form = Forms::Query.new.call(router.params)
            # TODO: passing query_form to service object

            # Examine the query
            begin
              query = router.params['query']
              if query.empty? # TODO: Use regex to avoid "   " inputs
                flash[:error] = 'This query is empty'
                router.redirect('/')
              end
            rescue exception # router.params.exclude 'query', not sure what the error type is
              flash[:error] = 'Query is not detected'
              router.redirect('/')
            end

            # Extract information and map to view object
            collector = DataCollector.new(App.config, query)
            jobs = collector.jobs
            skills = collector.skills
            skillset = Views::SkillJob.new(jobs, skills)

            begin
              flash[:notice] = "Your last query is '#{query}'"
              view 'details', locals: { query: query, skilljob: skillset }
            rescue NoMethodError => _e
              flash[:error] = "No skills extracted from '#{query}'"
              router.redirect('/')
            end
          end
        end
      end
    end

    # request jobs using API if the query has not saved to database
    class DataCollector
      def initialize(config, query)
        @job_mapper = Skiller::Reed::JobMapper.new(config)
        @query = query
        @jobs = nil
        @skillset = nil
      end

      def jobs
        if Repository::QueriesJobs.query_exist?(@query)
          Repository::QueriesJobs.find_jobs_by_query(@query)
        else
          @jobs = request_jobs_and_update_database(@query)
          @jobs
        end
      end

      def skills
        if Repository::QueriesJobs.query_exist?(@query)
          Repository::QueriesJobs.find_skills_by_query(@query)
        else
          extract_skillset
        end
      end

      def extract_skillset
        skill_list = extract_skills_and_update_database.reduce(:+)
        Repository::QueriesJobs.find_or_create(@query, @jobs.map(&:db_id))
        skill_list
      end

      def extract_skills_and_update_database
        # [ TODO ] analyze skillset from more data
        @jobs[..10].map do |job|
          if Repository::JobsSkills.job_exist?(job)
            Repository::JobsSkills.find_skills_by_job_id(job.db_id)
          else
            job = request_full_job_and_update_database(job)
            skills = Skiller::Skill::SkillMapper.new(job).skills
            Repository::JobsSkills.find_or_create(skills)
          end
        end
      end

      def request_jobs_and_update_database(query)
        job_list = @job_mapper.job_list(query)
        job_list.map do |job|
          Repository::Jobs.find_or_create(job)
        end
      end

      def request_full_job_and_update_database(job)
        db_job = Repository::Jobs.find(job)
        full_job = @job_mapper.job(db_job.job_id, db_job)
        Repository::Jobs.update(full_job)
        Repository::Jobs.find(full_job)
      end
    end
  end
end
