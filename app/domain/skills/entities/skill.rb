# frozen_string_literal: true

require 'dry-struct'
require_relative '../../jobs/values/salary'

module Skiller
  module Entity
    # Skill information
    class Skill < Dry::Struct
      include Dry.Types
      attribute :id, Integer.optional
      attribute :name, Strict::String
      attribute :job_db_id, Integer.optional
      attribute :salary, Skiller::Value::Salary.optional
    end
  end
end
