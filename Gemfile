ruby '>= 3.0.2'
source 'https://rubygems.org'

gem 'base64'
gem 'rack'
gem 'rack-contrib'
gem 'slim'
gem 'tzinfo'

source 'https://www.jubigems.org' do
  gem 'core'
end

group :development do
  gem 'apparition', github: 'jubishop/apparition'
  gem 'capybara'
  gem 'puma'
  gem 'rack-test'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'

  source 'https://www.jubigems.org' do
    gem 'core-test'
    gem 'rakegem'
    gem 'tony-test'
  end
end

# Specify your gem's dependencies in tony.gemspec
gemspec
