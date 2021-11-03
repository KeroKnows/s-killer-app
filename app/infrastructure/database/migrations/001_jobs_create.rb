# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:jobs) do
      # Method name # Column
      primary_key :id

      Integer     :job_id, unique: true
      String      :job_title
      String      :partial_description
      String      :location
      Float       :yearly_minimum_salary
      Float       :yearly_maximum_salary
      String      :currency
      String      :job_url

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end