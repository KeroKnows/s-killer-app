# frozen_string_literal: true

require 'dry-struct'

module Skiller
  module Value
    # Library for salary information
    class Salary < Dry::Struct
      include Dry.Types
      attribute :year_min, Float.optional
      attribute :year_max, Float.optional
      attribute :currency, String.optional

      def year_avg
        return nil unless !year_min.nil? && !year_max.nil?

        (year_min + year_max) / 2
      end
    end
  end
end
