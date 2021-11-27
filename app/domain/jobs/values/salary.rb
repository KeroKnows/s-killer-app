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

      # :reek:NilCheck
      def year_avg
        return nil unless !year_min.nil? && !year_max.nil?

        (year_min + year_max) / 2
      end

      def exchange_currency(new_currency)
        exchange_rate = Skiller::FreeCurrency::ExchangeRateMapper.new(Skiller::App.config).exchange_rate(currency,
                                                                                                         new_currency)
        Salary.new(
          year_min: year_min ? year_min * exchange_rate : nil,
          year_max: year_max ? year_max * exchange_rate : nil,
          currency: new_currency
        )
      end
    end
  end
end
