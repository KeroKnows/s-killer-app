# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:skills) do
      # Method name # Column
      primary_key :id

      String      :name, unique: true
    end
  end
end
