require 'core'
require 'rack'

module Tony
  class App
    def initialize(secret: nil)
      @secret = secret
      @routes = Hash.new { |hash, key| hash[key] = {} }
    end

    def call(env)
      req = Request.new(env, secret: @secret)
      resp = Response.new(secret: @secret)

      @routes[req.request_method].each_value { |route|
        next unless (match = route.match?(req.path))

        req.params.merge!(match.named_captures) if match.is_a?(MatchData)
        req.params.symbolize_keys!
        begin
          run_block(route.block, req, resp)
        rescue Exception => error # rubocop:disable Lint/RescueException
          raise error unless @error_block

          resp.error = error
          resp.status = 500
          run_block(@error_block, req, resp)
        end
        return resp.finish
      }

      resp.status = 404
      run_block(@not_found_block, req, resp) if @not_found_block
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

    def post(path, block)
      @routes['POST'][path] = Route.new(path, block)
    end

    private

    def run_block(block, req, resp)
      status, message = catch(:response) { block.call(req, resp) }
      return unless status.is_a?(Integer) && message.is_a?(String)

      resp.status = status
      resp.write(message)
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
