module Tony
  module Cryptable
    def crypt
      return @crypt if @crypt

      raise(ArgumentError, 'Need :secret') unless @options.key?(:secret)

      return @crypt = Utils::Crypt.new(@options[:secret])
    end
  end
end
