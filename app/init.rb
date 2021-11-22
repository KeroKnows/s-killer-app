# frozen_string_literal: true

folders = %w[infrastructure domain presentation controllers]
folders.each do |folder|
  require_relative "#{folder}/init"
end
