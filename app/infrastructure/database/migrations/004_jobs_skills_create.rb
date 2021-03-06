# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:jobs_skills) do
      # Method name # Column
      primary_key :id
      foreign_key :job_db_id, :jobs, on_delete: :cascade
      foreign_key :skill_id, :skills, on_delete: :cascade
    end
  end
end
