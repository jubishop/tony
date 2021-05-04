require 'base64'
require 'openssl'
require 'rack'

module Tony
  module Utils
    class Crypt
      def initialize(secret)
        secret = secret.to_s
        unless secret.length >= 16
          raise(ArgumentError, 'secret must have length >= 16')
        end

        @encryption_key = hmac('Encryption', secret)
        @authentication_key = hmac('Authentication', secret)
      end

      def en(message)
        encrypted = encrypt_message(message)
        return Base64.urlsafe_encode64(
            authenticate_message(encrypted) + encrypted,
            padding: false)
      end

      def de(ciphertext)
        ciphertext = Base64.urlsafe_decode64(ciphertext)
        tag = ciphertext[0, hmac_length]
        ciphertext = ciphertext[hmac_length..]
        return unless tag && ciphertext && verify_message(tag, ciphertext)

        return decrypt_ciphertext(ciphertext)
      end

      private

      def hmac(secret, message)
        OpenSSL::HMAC.digest('SHA256', secret, message)
      end

      def hmac_length
        OpenSSL::Digest.new('SHA256').size
      end

      def verify_message(tag, message)
        return Rack::Utils.secure_compare(tag, authenticate_message(message))
      end

      def authenticate_message(message)
        return hmac(@authentication_key, message)
      end

      def encrypt_message(message)
        aes = OpenSSL::Cipher.new('aes-256-cbc').encrypt
        iv = aes.random_iv
        aes.key = @encryption_key
        aes.iv = iv
        return iv + aes.update(message) + aes.final
      end

      def decrypt_ciphertext(ciphertext)
        aes = OpenSSL::Cipher.new('aes-256-cbc').decrypt
        iv = ciphertext[0, aes.iv_len]
        return if iv.nil?

        aes.key = @encryption_key
        aes.iv = iv
        crypted_text = ciphertext[aes.iv_len..]
        return if crypted_text.nil?

        return aes.update(crypted_text) + aes.final
      rescue StandardError
        return
      end
    end
  end
end
