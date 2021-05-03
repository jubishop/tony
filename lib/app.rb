require 'rack'

require_relative 'response'

module Tony
  class App
    def initialize(app = Rack::NotFound.new, **options)
      @app, @options = app, options
      @routes = Hash.new { |hash, key| hash[key] = [] }
    end

    def call(env)
      req = Rack::Request.new(env)
      resp = Response.new

      @routes[req.request_method].each { |route|
        next unless (match = route.match?(req.path))

        puts match if match.is_a?(MatchData) # TODO: named_captures
        route.block.call(req, resp)
        return resp.finish
      }

      if @not_found_block
        resp.status = 404
        @not_found_block.call(req, resp)
        return resp.finish
      end

      return @app.call(env)
    end

    def not_found(block)
      @not_found_block = block
    end

    def get(path, block)
      @routes['GET'].push(Route.new(path, block))
    end

    class Route
      attr_accessor :path, :block

      def initialize(path, block)
        @path, @block = path, block
      end

      def match?(path)
        return @path.match(path) if @path.is_a?(Regexp)

        return path == @path
      end
    end
  end
end
