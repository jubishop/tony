require 'rack'

module Tony
  class Request < Rack::Request
    def initialize(env, **options)
      super(env)
      @options = options
    end

    def get_cookie(key)
      return crypt.de(cookies[key])
    end

    private

    def crypt
      return @crypt if @crypt

      unless @options.key?(:cookie_secret)
        raise(ArgumentError, 'Need :cookie_secret')
      end

      return @crypt = Utils::Crypt.new(@options[:cookie_secret])
    end
  end
end
