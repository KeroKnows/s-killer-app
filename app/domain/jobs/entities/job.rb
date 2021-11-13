# frozen_string_literal: true

require 'dry-struct'
require_relative 'partial_job'
require_relative '../values/salary'

module Skiller
  module Entity
    # Job information from Reed Details API
    class Job < PartialJob
      attribute :id, Types::Optional::Integer
      attribute :salary, Skiller::Value::Salary
      attribute :url, Types::Optional::String
    end
  end
end
