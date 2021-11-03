# frozen_string_literal: true

require 'rake/testtask'

CODE = 'config/ app/'

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

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info
    require_relative 'spec/helpers/database_helper'

    def app()
      Skiller::App
    end
  end

  desc 'Run migrations'
  task :migrate => :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.DB, 'app/infrastructure/database/migrations')
  end

  desc 'Wipe records from all tables'
  task :wipe => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task :drop => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(Skiller::App.config.DB_FILENAME)
    puts "Deleted #{Skiller::App.config.DB_FILENAME}"
  end
end

namespace :quality do
  task all: %i[rubocop flog reek]

  desc "flog: check #{CODE}"
  task :flog do
    sh "flog -m #{CODE}"
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
