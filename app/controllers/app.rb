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
            jobs = Reed::PartialJobMapper.new(CONFIG).job_list(query)

            view 'details', locals: { query: query, jobs: jobs }
          end
        end
      end
    end
  end
end
