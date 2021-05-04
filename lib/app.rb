require 'core'
require 'rack'

require_relative 'request'
require_relative 'response'

module Tony
  class App
    def initialize(**options)
      @options = options
      @routes = Hash.new { |hash, key| hash[key] = {} }
    end

    def call(env)
      req = Request.new(env, **@options)
      resp = Response.new(**@options)

      @routes[req.request_method].each_value { |route|
        next unless (match = route.match?(req.path))

        req.params.merge!(match.named_captures) if match.is_a?(MatchData)
        req.params.symbolize_keys!
        begin
          catch(:response) { route.block.call(req, resp) }
        rescue StandardError => error
          raise error unless @error_block

          resp.error = error
          resp.status = 500
          @error_block.call(req, resp)
        end

        return resp.finish
      }

      resp.status = 404
      @not_found_block&.call(req, resp)
      return resp.finish
    end

    def not_found(block)
      @not_found_block = block
    end

    def error(block)
      @error_block = block
    end

    def get(path, block)
      @routes['GET'][path] = Route.new(path, block)
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
