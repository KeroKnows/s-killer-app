# frozen_string_literal: true

require 'dry-struct'

module Skiller
  module Entity
    # Library for job information
    class PartialJob < Dry::Struct
      include Dry.Types
      attribute :job_id, Strict::String
      attribute :title, Strict::String
      attribute :description, Strict::String
      attribute :location, Strict::String
    end
  end
end
