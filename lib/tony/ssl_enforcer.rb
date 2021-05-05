require 'rack'

module Tony
  class SSLEnforcer
    def initialize(app, **options)
      @app = app
      @options = options
    end

    def call(env)
      req = Rack::Request.new(env)
      if req.scheme == 'http' || req.env['HTTP_X_FORWARDED_SSL'] == 'off'
        location = "https://#{req.host_with_port}#{req.fullpath}"
        body = <<~HTML
          <html>
            <body>
              You are being <a href="#{location}">redirected</a>.
            </body>
          </html>
        HTML
        return [
          301,
          # rubocop:disable Style/StringHashKeys
          { 'Content-Type' => 'text/html', 'Location' => location },
          # rubocop:enable Style/StringHashKeys
          [body]
        ]
      end
      return @app.call(env)
    end
  end
end
