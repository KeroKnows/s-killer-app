# frozen_string_literal: false

require 'dry-types'

module Skiller
  module Entity
    # Add dry types to Entity module
    module Types
      include Dry.Types()
    end
  end
end

Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  require file
end
