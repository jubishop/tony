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

    it('returns default 200 status on post') {
      app.post('/', ->(_, resp) {})
      post '/'
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
        raise RuntimeError, 'Hi' # rubocop:disable Style/RedundantException
      })
      app.error(->(_, resp) {
        resp.write(resp.error.message)
      })
      get '/'
      expect(last_response.status).to(be(500))
      expect(last_response.body).to(eq('Hi'))
    }

    it('rewrites a getter if same path passed twice') {
      app.get('/', ->(_, resp) {
        resp.write('Should Not See')
      })
      app.get('/', ->(_, resp) {
        resp.write('Hello World')
      })
      get '/'
      expect(last_response.body).to(eq('Hello World'))
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
      app.get(%r{^/artist/(?<artist>.+?)/(?<album>.+?)$}, ->(req, resp) {
        resp.write("#{req.params[:artist]}: #{req.params[:album]}")
      })
      get '/artist/Tony_Bennett/For_Once_in_My_Life'
      expect(last_response.body).to(eq('Tony_Bennett: For_Once_in_My_Life'))
    }

    it('fails gracefully when nothing found') {
      app.get(%r{^/artist/(?<artist>.+?)/(?<album>.+?)$}, ->(req, resp) {
        resp.write("#{req.params[:artist]}: #{req.params[:album]}")
      })
      get '/not_found'
      expect(last_response.status).to(be(404))
    }
  }

  context('simple regex') {
    before(:each) {
      @app = Tony::App.new
      app.get(%r{^/artist$}, ->(_, resp) {
        resp.write('Hello World')
      })
    }

    it('matches on regex') {
      get '/artist'
      expect(last_response.body).to(eq('Hello World'))
    }

    it('fails gracefully when nothing found') {
      get '/actor'
      expect(last_response.status).to(be(404))
    }
  }

  context('cookie management') {
    it('sets cookies in response in https') {
      @app = Tony::App.new(secret: 'fly_me_to_the_moon')
      app.get('/', ->(_, resp) {
        resp.set_cookie(:tony, 'bennett')
      })
      # rubocop:disable Style/StringHashKeys
      get '/', {}, { 'HTTPS' => 'on' }
      # rubocop:enable Style/StringHashKeys
      expect(get_cookie(:tony)).to(eq('bennett'))
      cookie = rack_mock_session.cookie_jar.get_cookie('tony')
      expect(cookie.path).to(eq('/'))
      expect(cookie.expires).to(eq(Time.at((2**31) - 1)))
    }

    it('gives no cookie over http in production') {
      ENV['APP_ENV'] = 'production'
      @app = Tony::App.new(secret: 'fly_me_to_the_moon')
      app.get('/', ->(_, resp) {
        resp.set_cookie(:tony, 'bennett')
      })
      get '/'
      expect(get_cookie('tony')).to(eq(''))
    }

    it('gets cookies from request') {
      @app = Tony::App.new(secret: 'fly_me_to_the_moon')
      app.get('/', ->(req, resp) {
        resp.write(req.get_cookie(:tony))
      })
      set_cookie('tony', 'bennett')
      get '/'
      expect(last_response.body).to(eq('bennett'))
    }

    it('raises error if you try set a cookie with no secret') {
      @app = Tony::App.new
      app.get('/', ->(_, resp) {
        resp.set_cookie(:tony, 'bennett')
      })
      expect { get('/') }.to(raise_error(ArgumentError))
    }

    it('raises error if you try to get a cookie with no secret') {
      @app = Tony::App.new
      app.get('/', ->(req, resp) {
        resp.write(req.get_cookie(:tony))
      })
      expect { get('/') }.to(raise_error(ArgumentError))
    }

    it('returns empty string if your secret is wrong') {
      @app = Tony::App.new(secret: 'for_once_in_my_life')
      app.get('/', ->(req, resp) {
        resp.write(req.get_cookie(:tony))
      })
      set_cookie('tony', 'bennett')
      get '/'
      expect(last_response.body).to(eq(''))
    }
  }
}
