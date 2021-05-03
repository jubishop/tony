require 'core'
require 'rack'

module Tony
  class App
    def initialize(app = Rack::NotFound.new, **options)
      @app = app
      @options = options
      @gets = []
    end

    def call(env)
      req = Rack::Request.new(env)
      if req.get?
        route = @gets.find { |get| get.match?(req.path) }
        return get_result(*route.block.run(req)) if route
      end

      return app.call(env)
    end

    def get(path, &block)
      @gets.push(Route.new(path, block))
    end

    def get_result(body, status = 200, headers = {})
      headers.transform_keys!(&:to_s)
      return [status, headers, [body]]
    end

    def post_result(body, status = 201, **headers)
      return [status, headers, [body]]
    end

    class Route
      attr_accessor :path, :block

      def initialize(path, block)
        @path = path
        @block = block
      end

      def match?(path)
        return true if path == @path
      end
    end
  end
end
