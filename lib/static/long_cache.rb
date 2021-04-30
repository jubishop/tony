require 'rack'

module Tony
  class LongCache
    def initialize(app)
      @app = app
      @file_server = Rack::File.new(::File.join(Dir.pwd, PUBLIC_FOLDER))
    end

    def call(env)
      req = Rack::Request.new(env)
      return @app.call(env) unless req.get?

      status, headers, body = @file_server.call(env)
      return @app.call(env) if status == 404

      headers['Cache-Control'] = 'public, max-age=31536000, immutable'
      return [status, headers, body]
    end
  end
end
