# frozen_string_literal: true

folders = %w[database reed freecurrency]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
