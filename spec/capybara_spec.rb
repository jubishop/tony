RSpec.describe(Tony, type: :feature) {
  let(:app) { Tony::App.new }

  before(:each) {
    Capybara.app = app
  }

  it('fetches timezone via script') {
    slim = Tony::Slim.new(views: 'spec/assets/views',
                          layout: 'spec/assets/views/layouts/script_helpers')
    app.get('/', ->(_, resp) {
      resp.write(slim.render(:basic))
    })
    app.get('/timezone', ->(req, _) {
      expect(req.timezone.utc_offset).to(eq(Time.now.utc_offset))
    })
    visit '/'
    visit '/timezone'
  }
}
