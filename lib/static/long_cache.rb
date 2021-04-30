require 'rack'

module Tony
  module Static
    class LongCache
      def initialize(app, **options)
        @app = app
        @options = {
          public_folder: 'public',
          headers: {
            'Cache-Control': 'public, max-age=31536000, immutable'
          }
        }.merge(options)
        @file_server = Rack::File.new(::File.join(Dir.pwd,
                                                  @options[:public_folder]))
      end

      def call(env)
        req = Rack::Request.new(env)
        return @app.call(env) unless req.get?

        status, headers, body = @file_server.call(env)
        return @app.call(env) if status == 404

        @options[:headers].each { |name, value|
          headers[name] = value
        }
        return [status, headers, body]
      end
    end
  end
end
