# frozen_string_literal: true

require 'dry-struct'
require_relative '../values/salary'

module Skiller
  module Entity
    # Job information from Reed Details API
    class Job < Dry::Struct
      include Dry.Types
      attribute :db_id, Integer.optional
      attribute :job_id, Strict::Integer
      attribute :title, Strict::String
      attribute :description, Strict::String
      attribute :location, Strict::String
      attribute :salary, Skiller::Value::Salary
      attribute :url, String.optional
      attribute :isfull, Strict::Bool
    end
  end
end
