# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

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
        router.is do
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
            # collector = DataCollector.new(App.config, query)
            # jobs, skills = collector.collect_jobs_and_skills
            # salary_distribution = Entity::SalaryDistribution.new(jobs.map(&:salary))
            skill_analysis = Service::AnalyzeSkills.new.call(query_form)
            if skill_analysis.failure?
              puts 'failure'
            else
              puts 'success'
            end
            skills = skill_analysis.value!

            skillset = Views::SkillJob.new(skills[:jobs], skills[:skills], skills[:salary_dist])

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
        @skills = nil
      end

      def collect_jobs_and_skills
        if Repository::QueriesJobs.query_exist?(@query)
          @jobs = Repository::QueriesJobs.find_jobs_by_query(@query)
          @skills = Repository::QueriesJobs.find_skills_by_query(@query)
        else
          @jobs = request_jobs_and_update_database
          @skills = extract_skills_and_update_database
        end
        [@jobs, @skills]
      end

      def request_jobs_and_update_database
        # [ TODO ] analyze skillset from more data
        jobs = @job_mapper.job_list(@query)[..10].map do |job|
          full_job = @job_mapper.job(job.job_id)
          Repository::Jobs.find_or_create(full_job)
        end
        Repository::QueriesJobs.find_or_create(@query, jobs.map(&:db_id))
        jobs
      end

      def extract_skills_and_update_database
        skills = @jobs.map do |job|
          if Repository::JobsSkills.job_exist?(job)
            Repository::JobsSkills.find_skills_by_job_id(job.db_id)
          else
            skills = Skiller::Skill::SkillMapper.new(job).skills
            Repository::JobsSkills.find_or_create(skills)
          end
        end
        skills.reduce(:+)
      end
    end
  end
end
