# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:queries_jobs) do
      # Method name # Column
      primary_key :id
      foreign_key :job_db_id, :jobs, on_delete: :cascade

      String      :query
    end
  end
end
