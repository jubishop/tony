RSpec.describe(Tony::SSLEnforcer, type: :rack_test) {
  let(:app) { Tony::SSLEnforcer.new(->(_) { [200, {}, ['Hello World']] }) }

  it('passes through fine when https') {
    get 'https://www.example.com/test'
    expect(last_response.body).to(eq('Hello World'))
    expect(last_response.status).to(eq(200))
  }

  it('redirects on basic http requests') {
    # rubocop:disable Style/StringHashKeys
    get 'http://www.example.com/test', { 'query' => 'param' }
    # rubocop:enable Style/StringHashKeys
    expect(last_response.status).to(eq(301))
    expect(last_response['Location']).to(
        eq('https://www.example.com/test?query=param'))
  }

  it('redirects based on `HTTP_X_FORWARDED_SSL`') {
    # rubocop:disable Style/StringHashKeys
    get 'https://www.example.com/', {}, { 'HTTP_X_FORWARDED_SSL' => 'off' }
    # rubocop:enable Style/StringHashKeys
    expect(last_response.status).to(eq(301))
    expect(last_response['Location']).to(eq('https://www.example.com/'))
  }
}
