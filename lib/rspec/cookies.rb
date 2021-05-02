require_relative '../../lib/utils/crypt'

module Tony
  module RSpec
    module Cookies
      def set_cookie(name, value)
        crypt = Tony::Utils::Crypt.new(cookie_secret)
        rack_mock_session.cookie_jar[name] = crypt.en(value)
      end

      def get_cookie(name)
        crypt = Tony::Utils::Crypt.new(cookie_secret)
        return crypt.de(rack_mock_session.cookie_jar[name])
      end
    end
  end
end
