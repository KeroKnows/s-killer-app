# frozen_string_literal: true

require 'dry-validation'

module Skiller
  module Forms
    QUERY_REGEX = /^(?!\s)[a-zA-Z ]+/

    # Form object to validate query
    class Query < Dry::Validation::Contract
      params do
        required(:query).filled(:string)
      end

      rule(:query) do
        # unless QUERY_REGEX.match?(value)
        #   key.failure('is an invalid request')
        # end
        key.failure('is an invalid request') unless QUERY_REGEX.match?(value)
      end
    end
  end
end
