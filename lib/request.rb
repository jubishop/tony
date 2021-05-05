require 'rack'

module Tony
  class Request < Rack::Request
    def initialize(env, secret: nil, old_secret: nil)
      super(env)
      @secret = secret
      @old_secret = old_secret
    end

    def get_cookie(key)
      return crypt.de(cookies[key]) || old_crypt&.de(cookies[key])
    end

    private

    def crypt
      return @crypt ||= Utils::Crypt.new(@secret)
    end

    def old_crypt
      return unless @old_secret

      return @old_crypt ||= Utils::Crypt.new(@old_secret)
    end
  end
end
