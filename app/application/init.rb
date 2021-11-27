# frozen_string_literal: true

folders = %w[controllers forms]
folders.each do |folder|
  require_relative "#{folder}/init"
end
