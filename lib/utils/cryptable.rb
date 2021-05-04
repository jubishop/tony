module Tony
  module Cryptable
    def crypt
      return @crypt ||= Utils::Crypt.new(secret)
    end
  end
end
