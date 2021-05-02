require_relative '../../lib/utils/crypt'

module Tony
  module RSpec
    module Cookies
      def set_cookie(name, value)
        rack_mock_session.cookie_jar[name] = Tony::Utils::Crypt.en(value)
      end

      def get_cookie(name)
        return Tony::Utils::Crypt.de(rack_mock_session.cookie_jar[name])
      end
    end
  end
end
