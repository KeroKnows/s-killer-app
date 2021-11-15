# frozen_string_literal: true

require_relative 'jobs'

module Skiller
  module Repository
    # lookup class to find the right repository for a given entity
    class For
      ENTITY_REPOSITORY = {
        Entity::Job => Repository::Jobs
      }.freeze

      def self.klass(entity_klass)
        ENTITY_REPOSITORY[entity_klass]
      end

      def self.entity(entity_object)
        ENTITY_REPOSITORY[entity_object.class]
      end
    end
  end
end
