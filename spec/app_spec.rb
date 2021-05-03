RSpec.describe(Tony::App, type: :rack_test) {
  let(:app) { @app }
  before(:each) {
    @app = Tony::App.new
  }

  context('simple route matching') {
    it('matches / page') {
      app.get('/') {
        return 'Hello World'
      }
      get '/'

      expect(last_response.ok?).to(be(true))
      expect(last_response.body).to(eq('Hello World'))
    }
  }

  context('custom status') {
    it('passes on custom status') {
      app.get('/') {
        return 'Hello World', 418
      }
      get '/'

      expect(last_response.status).to(be(418))
    }
  }

  context('custom headers') {
    it('passes on custom headers') {
      app.get('/') {
        return 'Hello World', 418, CUSTOM: 'HEADER'
      }
      get '/'

      expect(last_response.headers['CUSTOM']).to(eq('HEADER'))
    }
  }
}
