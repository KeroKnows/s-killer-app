# frozen_string_literal: true

# https://github.com/laserlemon/figaro

require 'roda'
require 'yaml'
require 'figaro'
require 'sequel'
require 'delegate'

module Skiller
  # Configuration for the App
  class App < Roda
    plugin :environments

    configure do
      # Environment variables setup
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load

      # Make the environment variables accessible
      def self.config
        Figaro.env
      end

      # configure :development, :test do
      #   ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
      # end

      # Database Setup
      # DB = Sequel.connect(ENV['DATABASE_URL']) # rubocop:disable Lint/ConstantDefinitionInBlock
      # :reek:UncommunicativeMethodName
      # def self.DB # rubocop:disable Naming/MethodName
        # DB
      # end
    end

    use Rack::Session::Cookie, secret: config.SESSION_SECRET
  end
end
