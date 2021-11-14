# frozen_string_literal: true

require 'yaml'
require 'nokogiri'

module Skiller
  module SkillAnalyzer
    # Extract the skillset from Skiller::Entity::Job
    class Extractor
      PYTHON = 'python3' # may need to change this to `python`, depending on your system
      SCRIPT = 'app/infrastructure/skill_extractor/extract.py'

      def initialize(job)
        @job = job
        @description = html_to_text
      end

      def html_to_text
        node = Nokogiri::HTML(@job.description)
        node.xpath('//text()').to_a.join(' ')
      end

      def extract
        result = `#{PYTHON} #{SCRIPT} "#{@description}"`
        YAML.safe_load result
      end
    end
  end
end
