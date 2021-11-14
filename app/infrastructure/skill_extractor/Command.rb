# frozen_string_literal: true

require 'yaml'
require 'nokogiri'

module Skiller
  module SkillAnalyzer
    class Extractor
      PYTHON = 'python3' # may need to change this to `python`, depending on your system
      SCRIPT = 'app/infrastructure/skill_extractor/extract.py'

      def initialize(job)
        @job = job
        @description = extract_description(job)
      end

      def extract_text(job)
        node = Nokogiri::HTML(job.description)
        node.xpath('//text()').to_a.join(' ')
      end

      def parse(result)
        YAML.safe_load result
      end

      def call
        parse `#{PYTHON} #{SCRIPT} "#{@description}"`
      end
    end
  end
end