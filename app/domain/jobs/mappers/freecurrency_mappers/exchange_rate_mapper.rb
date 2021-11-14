# frozen_string_literal: true

require_relative '../../values/salary'

module Skiller
  module FreeCurrency
    # fetch the exchanging rate between two currencies
    class ExchangeRateMapper
      def initialize(config, gateway_class = FreeCurrency::Api)
        @config = config
        @gateway = gateway_class.new(@config.FREECURRENCY_API_KEY)
      end

      def exchange_rate(src_currency, tgt_currency)
        return 1.0 if src_currency == tgt_currency

        exchange_rates = @gateway.exchange_rates(src_currency)['data']
        raise 'Invalid target currency' unless exchange_rates.key?(tgt_currency)

        exchange_rates[tgt_currency]
      end
    end
  end
end
