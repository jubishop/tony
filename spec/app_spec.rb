RSpec.describe(Tony::App, type: :rack_test) {
  let(:app) { @app }

  it('returns default 200 status on get') {
    @app = Tony::App.new
    app.get('/') { |_, resp|
      resp.body = 'Hello World'
    }
    get '/'

    expect(last_response.status).to(be(200))
  }

  context('simple getter') {
    before(:each) {
      @app = Tony::App.new
      app.get('/') { |_, resp|
        resp.body = 'Hello World'
        resp.status = 418
        resp.headers[:CUSTOM] = 'HEADER'
      }
      get '/'
    }

    it('returns body') {
      expect(last_response.body).to(eq('Hello World'))
    }

    it('passes on custom status') {
      expect(last_response.status).to(be(418))
    }

    it('passes on custom headers') {
      expect(last_response.headers['CUSTOM']).to(eq('HEADER'))
    }

    it('sets content-length') {
      expect(last_response.headers['Content-Length']).to(eq(11))
    }

    it('sets content type') {
      expect(last_response.headers['Content-Type']).to(
          eq('text/html;charset=utf-8'))
    }

    it('returns 404 when not found') {
      get '/does_not_exist'
      expect(last_response.status).to(be(404))
    }
  }

  context('as middleware') {
    before(:each) {
      @app = Tony::App.new(->(_) { [418, {}, []] })
    }

    it('continues to next app') {
      get '/'
      expect(last_response.status).to(eq(418))
    }
  }
}