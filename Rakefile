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

namespace :quality do
  desc 'run all quality checks'
  task all: %i[flog reek rubocop]

  task :flog do
    sh 'flog #{CODE}'
  end

  task :reek do
    sh 'reek'
  end

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