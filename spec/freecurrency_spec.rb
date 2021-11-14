# frozen_string_literal: true

require_relative 'helpers/vcr_helper'

describe 'Test FreeCurrency library' do
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_vcr_for_reed(FREECURRENCY_CASSETTE_FILE)
  end

  after do
    Skiller::VcrHelper.eject_vcr
  end

  describe 'HTTP communication of freecurrency API' do
    it 'HAPPY: should fetch with correct currency' do
      result = Skiller::FreeCurrency::Api.new(FREECURRENCY_API_KEY).exchange_rates(TEST_CURRENCY)
      _(result).wont_be_empty
    end

    it 'SAD: should raise exception on invalid api key' do
      _(proc do
        Skiller::FreeCurrency::Api.new('INVALID API KEY').exchange_rates(TEST_CURRENCY)
      end).must_raise Skiller::FreeCurrency::Errors::InvalidApiKey
    end

    it 'SAD: should raise exception on invalid currency' do
      _(proc do
        Skiller::FreeCurrency::Api.new(FREECURRENCY_API_KEY).exchange_rates('INVALID CURRENCY')
      end).must_raise Skiller::FreeCurrency::Errors::InvalidCurrency
    end
  end
end