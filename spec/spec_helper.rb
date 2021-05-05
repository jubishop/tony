require 'tony/test'

RSpec.shared_context(:rack_test) {
  include_context(:tony_rack_test)
}

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

  config.after(:each) {
    ENV['APP_ENV'] = 'test'
    ENV['RACK_ENV'] = 'test'
  }
end
