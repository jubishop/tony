RSpec.describe(Tony::App, type: :rack_test) {
  let(:app) { @app }

  context('basic behavior') {
    before(:each) {
      @app = Tony::App.new
    }

    it('returns default 200 status on get') {
      app.get('/', ->(_, resp) {})
      get '/'

      expect(last_response.status).to(be(200))
    }

    it('deals with returning from a block') {
      app.get('/', ->(_, resp) {
        resp.write('Heyo')
        return
      })
      get '/'

      expect(last_response.status).to(be(200))
      expect(last_response.body).to(eq('Heyo'))
    }

    it('catches throwing :response') {
      app.get('/', ->(_, resp) {
        resp.write('Ok')
        throw(:response)
      })
      get '/'

      expect(last_response.status).to(be(200))
      expect(last_response.body).to(eq('Ok'))
    }

    it('uses not_found() if route is not found') {
      app.not_found(->(_, resp) {
        resp.write('Not Found')
      })
      get '/'

      expect(last_response.status).to(be(404))
      expect(last_response.body).to(eq('Not Found'))
    }

    it('uses error() if an exception is raised') {
      app.get('/', ->(_, _) {
        raise StandardError, 'Whoopsydaisy'
      })
      app.error(->(_, resp) {
        resp.write(resp.error.message)
      })
      get '/'

      expect(last_response.status).to(be(500))
      expect(last_response.body).to(eq('Whoopsydaisy'))
    }
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

  context('with named captures') {
    before(:each) {
      @app = Tony::App.new
    }

    it('adds named captures to the params') {
      @app.get(%r{^/(?<artist>.+?)/(?<album>.+?)$}, ->(req, resp) {
        resp.write("#{req.params[:artist]}: #{req.params[:album]}")
      })

      get '/Tony_Bennett/For_Once_in_My_Life'
      expect(last_response.body).to(eq('Tony_Bennett: For_Once_in_My_Life'))
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
