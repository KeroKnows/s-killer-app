# frozen_string_literal: true

require_relative '../../entities/job'

module Skiller
  module Reed
    # get an array of `Job` using Reed::Api
    class JobMapper
      def initialize(config, gateway_class = Reed::Api)
        @config = config
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@config['REED_TOKEN'])
      end

      def job_list(keyword)
        data = @gateway.search(keyword)['results']
        data.map { |job_data| build_entity(job_data) }
      end

      def build_entity(data)
        DataMapper.new(data, @gateway).build_entity
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, gateway)
          @data = data
          @gateway = gateway
        end

        def build_entity
          Entity::ReedJob.new(
            id: @data['jobId'].to_s,
            title: @data['jobTitle'],
            description: @data['jobDescription'],
            location: @data['locationName'],
            reed_api: @gateway
          )
        end
      end
    end
  end
end
