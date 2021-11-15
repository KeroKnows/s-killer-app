# frozen_string_literal: true

folders = %w[jobs skills]
folders.each do |folder|
  require_relative "#{folder}/init"
end
