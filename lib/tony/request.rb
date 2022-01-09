require 'rack'
require 'tzinfo'

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

    def timezone
      @timezone ||= TZInfo::Timezone.get(cookies.fetch('tz', 'Asia/Bangkok'))
      return @timezone
    end

    def param(req, key, default = nil)
      if req.params[key].nil? || req.params[key].to_s.empty?
        return default unless default.nil?

        throw(:response, [400, "No #{key} given"])
      end

      return req.params.fetch(key)
    end

    def list_param(req, key, default = nil)
      items = param(req, key, default)

      unless items.is_a?(Enumerable)
        throw(:response, [400, "Invalid #{key} given"])
      end
      items.uniq!
      items.compact!
      items = items.delete_if { |item| item.to_s.empty? }
      return items if items == default

      throw(:response, [400, "No #{key} given"]) if items.empty?

      return items
    end

    private

    def crypt
      return @crypt ||= Utils::Crypt.new(@secret)
    end
  end
end
