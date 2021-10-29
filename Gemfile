# frozen_string_literal: true

source 'https://rubygems.org'

# Web App
gem 'puma', '~> 5.5'
gem 'roda', '~> 3.49'
gem 'slim', '~> 4.1'

# Networking
gem 'http', '~> 5.0'

# Testing
gem 'minitest', '~> 5.0'
gem 'minitest-rg', '~> 5.0'
gem 'simplecov', '~> 0'
gem 'vcr', '~> 6.0'
gem 'webmock', '~> 3.0'

# Utilities
gem 'rake'

# Code Quality
gem 'flog'
gem 'reek'
gem 'rubocop'

# Development
def os_is(re)
  RbConfig::CONFIG['host_os'] =~ re ? true : false
end

gem 'rerun'
gem 'rb-fsevent', platforms: :ruby, install_if: os_is(/darwin/)
gem 'rb-kqueue', platforms: :ruby, install_if: os_is(/linux/)
