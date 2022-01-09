require 'capybara/apparition'
require 'tony/test'

ENV['APP_ENV'] = 'test'
ENV['RACK_ENV'] = 'test'

Capybara.server = :puma
Capybara.default_max_wait_time = 5
Capybara.disable_animation = true

Capybara.register_driver(:apparition) { |app|
  Capybara::Apparition::Driver.new(app, {
    headless: !ENV.fetch('CHROME_DEBUG', false)
  })
}
Capybara.default_driver = :apparition

RSpec.shared_context(:rack_test) {
  include_context(:tony_rack_test)

  let(:cookie_secret) { 'fly_me_to_the_moon' }
}

RSpec.shared_context(:capybara) {
  include_context(:tony_capybara)

  let(:cookie_secret) { 'fly_me_to_the_moon' }
}

RSpec.configure do |config|
  config.expect_with(:rspec) do |expect|
    expect.include_chain_clauses_in_custom_matcher_descriptions = true
    expect.max_formatted_output_length = 200
  end

  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.default_formatter = 'doc'
  config.alias_it_should_behave_like_to(:it_has_behavior, 'has behavior:')

  config.order = :random
  Kernel.srand(config.seed)

  config.include_context(:rack_test, type: :rack_test)
  config.include_context(:capybara, type: :feature)

  config.after(:each) {
    ENV['APP_ENV'] = 'test'
    ENV['RACK_ENV'] = 'test'
  }
end
