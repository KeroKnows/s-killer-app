# frozen_string_literal: true

require 'dry-validation'

module Skiller
    module Forms
        class Query < Dry::Validation::Contract
            # QUERY_REGEX = %r{[a-zA-Z ]*}.freeze
            
            params do
                required(:query).filled(:string)
            end

            rule(:query) do
                unless /^(?!\s)[a-zA-Z ]+/i.match?(value)
                    key.failure('is an invalid request')
                end
            end
        end
    end
end