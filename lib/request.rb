require 'rack'

module Tony
  class Request < Rack::Request
    def initialize(env, **options)
      super(env)
      @options = options
    end

    def get_cookie(key)
      return crypt.de(cookies[key]) || old_crypt&.de(cookies[key])
    end

    private

    def crypt
      return @crypt ||= Utils::Crypt.new(@options.fetch(:secret))
    end

    def old_crypt
      return unless @options.key?(:old_secret)

      return @old_crypt ||= Utils::Crypt.new(@options.fetch(:old_secret))
    end
  end
end
