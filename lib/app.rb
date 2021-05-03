require 'core'
require 'rack'

module Tony
  class App
    def initialize(app = Rack::NotFound.new, **options)
      @app, @options = app, options
      @gets = []
    end

    def call(env)
      req = Rack::Request.new(env)
      if req.get? && (route = @gets.find { |get| get.match?(req.path) })
        resp = Response.new
        route.block.run(req, resp)
        return resp.finish
      end

      return @app.call(env)
    end

    def get(path, &block)
      @gets.push(Route.new(path, block))
    end

    class Route
      attr_accessor :path, :block

      def initialize(path, block)
        @path, @block = path, block
      end

      def match?(path)
        return true if path == @path
      end
    end

    class Response < Rack::Response
      def finish
        headers.transform_keys!(&:to_s)
        self['Content-Length'] ||= body.bytesize
        self['Content-Type'] ||= 'text/html;charset=utf-8'
        return super
      end
    end
  end
end
