require 'core'
require 'rack'
require 'slim'

require_relative 'request'
require_relative 'response'

module Tony
  class App
    def initialize(**options)
      @options = { views: 'views', layout: 'views/layout.slim' }.merge!(options)
      @routes = Hash.new { |hash, key| hash[key] = {} }

      begin
        @layout = Slim::Template.new(@options[:layout])
      rescue StandardError
        @layout = nil
      end
    end

    def call(env)
      req = Request.new(env, **@options)
      resp = Response.new(@template, **@options)

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
  end

  Route = Struct.new(:path, :block) {
    def match?(path)
      return self.path.match(path) if self.path.is_a?(Regexp)

      return self.path == path
    end
  }
  private_constant :Route
end
