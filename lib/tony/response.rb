require 'rack'

module Tony
  class Response < Rack::Response
    undef :body= # use write()

    attr_accessor :error

    def initialize(secret: nil)
      super()
      @secret = secret
    end

    def finish
      headers.transform_keys!(&:to_s)
      self.content_type ||= 'text/html;charset=utf-8'
      return super
    end

    def set_cookie(key, value)
      super(key, value: crypt.en(value),
                 path: '/',
                 expires: Time.at(2**31 - 1),
                 secure: ENV.fetch('APP_ENV') == 'production',
                 httponly: true)
    end

    private

    def crypt
      return @crypt ||= Utils::Crypt.new(@secret)
    end
  end
end
