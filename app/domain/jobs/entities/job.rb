# frozen_string_literal: true

require 'dry-struct'
require_relative 'partial_job'

module Skiller
  module Entity
    # Job information from Reed Details API
    class Job < PartialJob
      attribute :id, Types::Optional::Integer
      attribute :min_year_salary, Types::Optional::Float
      attribute :max_year_salary, Types::Optional::Float
      attribute :currency, Types::Optional::String
      attribute :url, Types::Optional::String
    end
  end
end
