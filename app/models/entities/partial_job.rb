# frozen_string_literal: true

require 'dry-struct'

module Skiller
  module Entity
    # Library for job information
    class PartialJob < Dry::Struct
      attribute :id, Types::Strict::String
      attribute :title, Types::Strict::String
      attribute :description, Types::Strict::String
      attribute :location, Types::Strict::String
    end
  end
end
