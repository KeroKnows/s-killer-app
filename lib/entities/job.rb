# frozen_string_literal: true

require 'dry-struct'
require_relative '../gateways/reed_api'

module Skiller
  module Entity
    # Library for job information
    class PartialJob < Dry::Struct
      attribute :id, Types::Strict::String
      attribute :title, Types::Strict::String
      attribute :description, Types::Strict::String
      attribute :location, Types::Strict::String
    end

    # Job information of jobs from Reed API
    class Job < PartialJob
      attribute :min_year_salary, Types::Optional::Float
      attribute :max_year_salary, Types::Optional::Float
      attribute :currency, Types::Optional::String
      attribute :url, Types::Optional::String
    end
  end
end
