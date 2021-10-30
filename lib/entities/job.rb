# frozen_string_literal: true

require 'dry-struct'
require_relative '../gateways/reed_api'

module Skiller
  module Entity
    # Library for job information
    class Job < Dry::Struct
      attribute :id, Types::Strict::String
      attribute :title, Types::Strict::String
      attribute :description, Types::Strict::String
      attribute :location, Types::Strict::String
    end

    # Job information of jobs from Reed API
    class ReedJob < Job
      attribute :reed_api, Types.Instance(Reed::Api)

      def request_full_info
        details = reed_api.details(id)
        Job.new(
          id: id,
          title: title,
          description: details['jobDescription'],
          location: location
        )
      end
    end
  end
end
