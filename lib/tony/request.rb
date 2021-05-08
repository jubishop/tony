require 'rack'

module Tony
  class Request < Rack::Request
    def initialize(env, secret: nil)
      super(env)
      @secret = secret
    end

    def get_cookie(key)
      key = key.to_s
      return crypt.de(cookies[key])
    end

    private

    def crypt
      return @crypt ||= Utils::Crypt.new(@secret)
    end
  end
end
