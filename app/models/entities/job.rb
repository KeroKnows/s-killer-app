# frozen_string_literal: true

require 'dry-struct'

module Skiller
  module Entity
    # Job information from Reed Details API
    class Job < PartialJob
      attribute :min_year_salary, Types::Optional::Float
      attribute :max_year_salary, Types::Optional::Float
      attribute :currency, Types::Optional::String
      attribute :url, Types::Optional::String
    end
  end
end
