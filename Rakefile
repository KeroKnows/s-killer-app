# frozen_string_literal: true

require 'rake/testtask'

CODE = 'config/ app/'

task :default do
  puts `rake -T`
end

desc 'run unit/integration tests'
task spec: 'spec:all'


# desc 'run acceptance tests with watir'
# task :spec_acceptance do
#   puts 'NOTE: run app in test environment in another process'
#   sh 'ruby spec/tests/acceptance/acceptance_spec.rb'
# end



desc 'start the app with file chages watched'
task :dev do
  sh "rerun -c 'bundle exec rackup -p 4001' --ignore 'coverage/*' --ignore 'spec/*' --ignore '*.slim'"
end

desc 'run all quality checks'
task quality: 'quality:all'

desc 'Run application console (irb)'
task :console do
  sh 'pry -r ./init.rb'
end

namespace :spec do
  # task acceptance: %i[acceptance]
  task all: %i[reed_api freecurrency_api skill_analyzer gateway_database view_objects]
  

  integration_test_path = 'spec/tests/integration'
  unit_test_path = 'spec/tests/unit'

  desc 'spec checks of Reed API'
  task :reed_api do
    sh "RACK_ENV=test bundle exec ruby #{unit_test_path}/reed_spec.rb"
  end

  desc 'spec checks of FreeCurrency API'
  task :freecurrency_api do
    sh "RACK_ENV=test bundle exec ruby #{unit_test_path}/freecurrency_spec.rb"
  end

  desc 'spec checks of Skill Analyzer'
  task :skill_analyzer do
    sh "RACK_ENV=test bundle exec ruby #{integration_test_path}/skill_spec.rb"
  end

  desc 'spec checks of the integration of gateway and database'
  task :gateway_database do
    sh "RACK_ENV=test bundle exec ruby #{integration_test_path}/gateway_database_spec.rb"
  end

  desc 'spec checks of View Objects'
  task :view_objects do
    sh "RACK_ENV=test bundle exec ruby #{integration_test_path}/view_objects_spec.rb"
  end

  desc 'run acceptance tests with watir'
  task :spec_acceptance do
    puts 'NOTE: run app in test environment in another process'
    sh 'ruby spec/tests/acceptance/acceptance_spec.rb'
  end
end

namespace :db do # rubocop:disable Metrics/BlockLength
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info
    require_relative 'spec/helpers/database_helper'

    def app
      Skiller::App
    end
  end

  desc 'Run migrations'
  task migrate: :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.DB, 'app/infrastructure/database/migrations')
  end

  desc 'Wipe records from all tables'
  task wipe: :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    require_relative 'spec/helpers/database_helper'
    Skiller::DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task drop: :config do
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
