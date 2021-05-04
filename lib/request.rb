require 'rack'

require_relative 'utils/cryptable'

module Tony
  class Request < Rack::Request
    include Cryptable

    def initialize(env, **options)
      super(env)
      @options = options
    end

    def get_cookie(key)
      return crypt.de(cookies[key])
    end

    private

    def secret
      return @options.fetch(:secret)
    end
  end
end
