require 'openssl'
require 'rack'
require 'single-instance'

module Tony
  class Crypt
    include SingleInstance

    def initialize(secret, cipher = 'aes-256-cbc', hmac = 'SHA256')
      @cipher = cipher
      @hmac   = hmac

      # use the HMAC to derive two independent keys for the encryption and
      # authentication of ciphertexts It is bad practice to use the same key
      # for encryption and authentication.  This also allows us to use all
      # of the entropy in a long key (e.g. 64 hex bytes) when straight
      # assignement would could result in assigning a key with a much
      # reduced key space.  Also, the personalisation strings further help
      # reduce the possibility of key reuse by ensuring it should be unique
      # to this gem, even with shared secrets.
      @encryption_key     = hmac('EncryptedCookie Encryption',     secret)
      @authentication_key = hmac('EncryptedCookie Authentication', secret)
    end

    # Encrypts message
    #
    # Returns the base64 encoded ciphertext plus IV.  In addtion, the
    # message is prepended with a MAC code to prevent chosen ciphertext
    # attacks.
    def en(message)
      # encrypt the message
      encrypted = encrypt_message(message)

      [authenticate_message(encrypted) + encrypted].pack('m0')
    end

    # decrypts base64 encoded ciphertext
    #
    # First, it checks the message tag and returns nil if that fails to verify.
    # Otherwise, the data is passed on to the AES function for decryption.
    def de(ciphertext)
      ciphertext = ciphertext.unpack1('m')
      tag        = ciphertext[0, hmac_length]
      ciphertext = ciphertext[hmac_length..]

      # make sure we actually had enough data for the tag too.
      return unless tag && ciphertext && verify_message(tag, ciphertext)

      decrypt_ciphertext(ciphertext)
    end

    private

    # HMAC digest of the message using the given secret
    def hmac(secret, message)
      OpenSSL::HMAC.digest(@hmac, secret, message)
    end

    def hmac_length
      OpenSSL::Digest.new(@hmac).size
    end

    # returns the message authentication tag
    #
    # This is computed as HMAC(authentication_key, message)
    def authenticate_message(message)
      hmac(@authentication_key, message)
    end

    # verifies the message
    #
    # This does its best to be constant time, by use of the rack secure compare
    # function.
    def verify_message(tag, message)
      own_tag = authenticate_message(message)
      Rack::Utils.secure_compare(tag, own_tag)
    end

    # Encrypt
    #
    # Encrypts the given message with a random IV, then returns the ciphertext
    # with the IV prepended.
    def encrypt_message(message)
      aes = OpenSSL::Cipher.new(@cipher).encrypt
      aes.key = @encryption_key
      iv = aes.random_iv
      aes.iv = iv
      iv + (aes.update(message) << aes.final)
    end

    # Decrypt
    #
    # Pulls the IV off the front of the message and decrypts.  Catches
    # OpenSSL errors and returns nil.  But this should never happen, as the
    # verify method should catch all corrupted ciphertexts.
    def decrypt_ciphertext(ciphertext)
      aes = OpenSSL::Cipher.new(@cipher).decrypt
      aes.key = @encryption_key
      iv = ciphertext[0, aes.iv_len]
      aes.iv = iv
      crypted_text = ciphertext[aes.iv_len..]
      return if crypted_text.nil? || iv.nil?

      aes.update(crypted_text) << aes.final
    rescue StandardError
      nil
    end
  end
end
