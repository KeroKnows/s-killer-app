# frozen_string_literal: true

require 'dry-struct'

module Skiller
  module Value
    class Salary < Dry::Struct
      attribute :year_min, Skiller::Entity::Types::Optional::Float
      attribute :year_max, Skiller::Entity::Types::Optional::Float
      attribute :currency, Skiller::Entity::Types::Optional::String

      def year_avg
        return nil unless year_min != nil and year_max != nil
        (year_min + year_max) / 2
      end
    end
  end
end