# frozen_string_literal: true

module Skiller
  module Entity
    # An entity object to estimate the statistical distribution of given salaries
    class SalaryDistribution
      attr_reader :maximum, :minimum, :currency

      def initialize(salaries, currency = 'TWD')
        @currency = currency
        @salaries = salaries.map do |salary|
          salary.exchange_currency(@currency)
        end
        @maximum = calculate_maximum
        @minimum = calculate_minimum
      end

      # :reek:FeatureEnvy
      def calculate_maximum
        salaries = @salaries.filter(&:year_max)
        salaries.length.positive? ? salaries.max_by(&:year_max).year_max : nil
      end

      # :reek:FeatureEnvy
      def calculate_minimum
        salaries = @salaries.filter(&:year_min)
        salaries.length.positive? ? salaries.min_by(&:year_min).year_min : nil
      end
    end
  end
end
