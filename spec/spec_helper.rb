require 'capybara/rspec'
require 'rack'
require 'rack/test'

require_relative '../lib/rspec/cookies'

RSpec.shared_context(:rack_test) do
  include Capybara::RSpecMatchers
  include Rack::Test::Methods
  include Tony::RSpec::Cookies

  after(:each) {
    clear_cookies
  }
end

RSpec.configure do |config|
  config.expect_with(:rspec) do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.default_formatter = 'doc'
  config.alias_it_should_behave_like_to(:it_has_behavior, 'has behavior:')

  config.order = :random
  Kernel.srand(config.seed)

  config.include_context(:rack_test, type: :rack_test)

  config.before(:each) {
    ENV['RACK_ENV'] = 'test'
    ENV['APP_ENV'] = 'test'
  }
end
