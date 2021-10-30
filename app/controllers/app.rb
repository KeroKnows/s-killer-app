# frozen_string_literal: true

require 'roda'
require 'slim'
require 'yaml' # develop

module Skiller
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :halt

    route do |router| 
      # GET /
      router.root do
        view 'index'
      end

      # GET /index
      router.on 'index' do
        router.is do
          view 'index'
        end
      end

      router.on 'details' do
        router.is do
          # GET /details?query=[query]
          router.get do
            router.halt 400 unless router.params.include? 'query'

            query = router.params['query']
            # jobs = Reed::ReedApi.new(REED_TOKEN).job_list(query)
            jobs = YAML.safe_load(File.read('spec/fixtures/job_lists.yml'))

            # data = [{
            #   'query' => query,
            #   'title' => jobs.first['title'],
            #   'description' => jobs.first['description']
            # }]
            view 'details', locals: { query: query, jobs: jobs }
          end
        end
        
      end
    end
  end
end
