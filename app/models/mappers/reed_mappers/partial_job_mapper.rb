# frozen_string_literal: true

require_relative '../../entities/job'

module Skiller
  module Reed
    # Get an array of `PartialJob` using Reed::Api
    class PartialJobMapper
      def initialize(config, gateway_class = Reed::Api)
        @config = config
        @gateway = gateway_class.new(@config['REED_TOKEN'])
      end

      # Get job_list from Reed::API and make each job a DataMapper class
      def job_list(keyword)
        data = @gateway.search(keyword)['results']
        data.map { |job_data| DataMapper.new(job_data).build_entity }
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          Entity::PartialJob.new(
            id: @data['jobId'].to_s,
            title: @data['jobTitle'],
            description: @data['jobDescription'],
            location: @data['locationName']
          )
        end
      end
    end
  end
end
