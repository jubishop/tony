RSpec.describe(Tony::Static, type: :rack_test) {
  context('file not found') {
    it('returns 404 if no more middleware left') {
      def app
        Tony::Static.new
      end

      get '/does_not_exist.css'
      expect(last_response.status).to(eq(404))
    }

    it('calls next middleware') {
      def app
        next_app = ->(_) {
          [418, { "Content-Type": 'text/plain' }, ["I'm a teapot'"]]
        }
        Tony::Static.new(next_app)
      end

      get '/does_not_exist.css'
      expect(last_response.status).to(eq(418))
    }
  }

  context('file found') {
    let(:app) { Tony::Static.new(public_folder: 'spec/assets') }

    it('returns top level file') {
      get '/test.css'
      expect(last_response.status).to(eq(200))
      expect(last_response.body).to(eq("body { color: black; }\n"))
    }

    it('returns file nested in folder') {
      get '/nested/test.css'
      expect(last_response.status).to(eq(200))
      expect(last_response.body).to(eq("body { color: white; }\n"))
    }

    it('returns cache-control public, immutable, and long') {
      get '/test.css'
      expect(last_response.headers['Cache-Control']).to(
          eq('public, max-age=31536000, immutable'))
    }
  }
}
