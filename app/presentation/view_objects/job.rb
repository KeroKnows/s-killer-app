#frozen_string_literial: true

require 'nokogiri'

module Views
  class Jobs
    def initialize(job)
      @job = job
      @description = nil
    end

    def title
      @job.title
    end

    def location
      @job.location
    end

    def brief
      "#{description[0,300]}..."
    end

    def description
      parse_description
      @description
    end

    # UTILITIES

    def parse_description
      return if @description

      # [ TODO ] extract text with line break
      doc = Nokogiri::HTML(@job.description)
      @description = doc.xpath('//text()').to_a.join(' ')
    end
  end
end