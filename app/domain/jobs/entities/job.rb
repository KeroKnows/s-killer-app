# frozen_string_literal: true

require 'dry-struct'
require_relative 'partial_job'
require_relative '../values/salary'

module Skiller
  module Entity
    # Job information from Reed Details API
    class Job < PartialJob
      include Dry.Types
      attribute :id, Integer.optional
      attribute :salary, Skiller::Value::Salary
      attribute :url, String.optional
    end
  end
end
