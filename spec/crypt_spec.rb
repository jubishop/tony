require_relative '../lib/utils/crypt'

RSpec.describe(Tony::Utils::Crypt) {
  it('encrypts and decrypts to the same thing') {
    crypt = Tony::Utils::Crypt.new('test secret')
    %w[hello world].each { |message|
      encrypted = crypt.en(message)
      expect(encrypted).to_not(eq(message))
      decrypted = crypt.de(encrypted)
      expect(decrypted).to(eq(message))
    }
  }
}
