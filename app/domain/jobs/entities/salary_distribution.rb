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

      def calculate_maximum
        salaries = @salaries.filter(&:year_max)
        salaries.length > 0 ? salaries.max_by(&:year_max).year_max : nil
      end

      def calculate_minimum
        salaries = @salaries.filter(&:year_min)
        salaries.length > 0 ? salaries.min_by(&:year_min).year_min : nil
      end
    end
  end
end
