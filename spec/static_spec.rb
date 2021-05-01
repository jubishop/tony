require_relative '../lib/static'

RSpec.describe(Tony::Static, type: :rack_test) {
  let(:app) { Tony::Static.new }

  it('returns 404 when file not found') {
    get '/does_not_exist.css'
    expect(last_response.status).to(eq(404))
  }
}
