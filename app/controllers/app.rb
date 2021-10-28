# frozen_string_literal: true

require 'roda'
require 'slim'

module Skiller
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :halt

    route do |routing| 

      # GET /
      routing.root do
        view 'index'
      end
    end
  end
end
