# frozen_string_literal: true

require 'yaml'
require 'nokogiri'

module Skiller
  module Skill
    # Extract the skillset from Skiller::Entity::Job
    class Extractor
      PYTHON = 'python3' # may need to change this to `python`, depending on your system
      SCRIPT = 'app/infrastructure/skill_extractor/extract.py'

      attr_reader :result

      def initialize(job)
        @job = job
        @description = gen_description
        @result = nil
      end

      def gen_description
        node = Nokogiri::HTML(@job.description)
        node.xpath('//text()').to_a.join(' ')
      end

      def extract
        @result = `#{PYTHON} #{SCRIPT} "#{@description}"`
        self
      end

      def parse
        raise 'Please extract skillset first' unless @result

        YAML.safe_load @result
      end
    end
  end
end
