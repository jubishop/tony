require 'rack'

require_relative 'utils/cryptable'

module Tony
  class Response < Rack::Response
    include Cryptable

    undef :body= # use write()

    attr_accessor :error

    def initialize(**options)
      super()
      @options = options
    end

    def finish
      headers.transform_keys!(&:to_s)
      self.content_type ||= 'text/html;charset=utf-8'
      return super
    end

    def set_cookie(key, value)
      super(key, crypt.en(value))
    end

    private

    def secret
      return @options.fetch(:secret)
    end
  end
end
