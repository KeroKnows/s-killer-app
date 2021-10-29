# frozen_string_literal: true

require 'rake/testtask'

CODE = 'lib/'

task :default do
  puts `rake -T`
end

desc 'run spec checks'
task :spec do
  sh 'ruby spec/reed_spec.rb'
end

desc 'start the app with file chages watched'
task :dev do
  sh "rerun -c 'rackup -p 4001' --ignore 'coverage/*' --ignore 'spec/*' --ignore '*.slim'"
end

desc 'run all quality checks'
task quality: 'quality:all'

namespace :quality do
  task all: %i[rubocop flog reek]

  desc "flog: check #{CODE}"
  task :flog do
    sh "flog #{CODE}"
  end

  desc 'reek check'
  task :reek do
    sh 'reek'
  end

  desc 'rubocop check'
  task :rubocop do
    sh 'rubocop'
  end
end

namespace :vcr do
  desc 'delete all cassettes'
  task :clean do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'All cassettes deleted' : 'No cassette is found')
    end
  end
end
