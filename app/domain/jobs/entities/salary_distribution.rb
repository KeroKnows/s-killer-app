# frozen_string_literal: true

module Skiller
  module Entity
    # An entity object to estimate the statistical distribution of given salaries
    class SalaryDistribution
      attr_reader :maximum, :minimum, :currency

      def initialize(salaries, currency = 'TWD')
        @currency = currency
        # @salaries = salaries.map do |salary|
        #   salary.exchange_currency(@currency)
        # end
        @salaries = salaries
        @maximum = calculate_maximum
        @minimum = calculate_minimum
      end

      def calculate_maximum
        salaries = filter_salary(:year_max)
        salaries.max_by(&:year_max)&.year_max
      end

      def calculate_minimum
        salaries = filter_salary(:year_min)
        salaries.min_by(&:year_min)&.year_min
      end

      def filter_salary(prop)
        @salaries.filter(&prop)
      end
    end
  end
end
