RSpec.describe(Tony::App, type: :rack_test) {
  let(:app) { @app }

  it('returns default 200 status on get') {
    @app = Tony::App.new
    app.get('/', ->(_, resp) {})
    get '/'

    expect(last_response.status).to(be(200))
  }

  it('deals with returning from a block') {
    @app = Tony::App.new
    app.get('/', ->(_, _) {
      return
    })
    get '/'

    expect(last_response.status).to(be(200))
  }

  it('does not allow writing to body') {
    @app = Tony::App.new
    app.get('/', ->(_, resp) {
      resp.body = 'Hello World'
    })

    expect { get('/') }.to(raise_error(NoMethodError))
  }

  it('uses not_found if called') {
    @app = Tony::App.new
    app.not_found(->(_, resp) {
      resp.write('Not Found')
    })
    get '/'

    expect(last_response.status).to(be(404))
    expect(last_response.body).to(eq('Not Found'))
  }

  context('simple getter') {
    before(:each) {
      @app = Tony::App.new
      app.get('/', ->(_, resp) {
        resp.write('Hello World')
        resp.status = 418
        resp.headers[:CUSTOM] = 'HEADER'
      })
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
      expect(last_response.headers['Content-Length']).to(eq('11'))
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
