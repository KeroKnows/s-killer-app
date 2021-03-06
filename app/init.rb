# frozen_string_literal: true

folders = %w[infrastructure domain presentation application]
folders.each do |folder|
  require_relative "#{folder}/init"
end
