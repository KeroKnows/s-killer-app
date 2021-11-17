# frozen_string_literal: true

require 'sequel'

module Skiller
  module Database
    # Object Relational Mapper for Job and PartialJob Entities
    class QueryJobOrm < Sequel::Model(:queries_jobs)
      many_to_one :job,
                  class: :'Skiller::Database::JobOrm',
                  key: :job_db_id
    end
  end
end
