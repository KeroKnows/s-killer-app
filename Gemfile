# frozen_string_literal: true

source 'https://rubygems.org'

# Developing tools
gem 'pry', '~> 0.13.1'

# Web App
gem 'figaro', '~> 1.2'
gem 'puma', '~> 5.5'
gem 'roda', '~> 3.49'
gem 'slim', '~> 4.1'

# Database
gem 'hirb', '~> 0'
gem 'hirb-unicode', '~> 0'
gem 'sequel', '~> 5.5'

group :development, :test do
  gem 'sqlite3', '~> 1.4'
end

# Validation
gem 'dry-struct', '~> 1.4'
gem 'dry-types', '~> 1.5'

# Networking
gem 'http', '~> 5.0'

# Testing
group :test do
  gem 'minitest', '~> 5.0'
  gem 'minitest-rg', '~> 5.0'
  gem 'simplecov', '~> 0'
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~> 3.0'
end

# Utilities
gem 'rake'

def os_is(pattern)
  RbConfig::CONFIG['host_os'] =~ pattern ? true : false
end
group :development do
  gem 'rb-fsevent', platforms: :ruby, install_if: os_is(/darwin/)
  gem 'rb-kqueue', platforms: :ruby, install_if: os_is(/linux/)
  gem 'rerun'
end
gem 'nokogiri', '~> 1.12'

# Code Quality
gem 'flog'
gem 'reek'
gem 'rubocop'
