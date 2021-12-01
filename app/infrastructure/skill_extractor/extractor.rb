# frozen_string_literal: true

require 'yaml'
require 'nokogiri'

module Skiller
  module Skill
    # Extract the skillset from Skiller::Entity::Job
    class Extractor
      PYTHON = 'python3' # may need to change this to `python`, depending on your system
      SCRIPT = File.join(File.dirname(__FILE__), 'extract.py')

      def initialize(job)
        @raw_description = job.description
        @random_seed = rand(10_000)
        @description = nil
        @script_result = nil
      end

      def skills
        analyze_skills
        YAML.safe_load(@script_result)
      end

      def description
        return @description if @description

        @description = parse_description
        @description
      end

      def analyze_skills
        tmp_file = File.join(File.dirname(__FILE__), ".extractor.#{@random_seed}.tmp")
        File.write(tmp_file, description, mode: 'w')
        @script_result = `#{PYTHON} #{SCRIPT} "#{tmp_file}"`
        File.delete(tmp_file)
      end

      def parse_description
        doc = Nokogiri::HTML(@raw_description)
        doc.xpath('//text()').to_a.join(' ')
      end
    end
  end
end
