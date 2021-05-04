require_relative '../lib/utils/crypt'

RSpec.describe(Tony::Utils::Crypt) {
  it('encrypts and decrypts to the same thing') {
    crypt = Tony::Utils::Crypt.new('fly_me_to_the_moon')
    %w[hello world].each { |message|
      encrypted = crypt.en(message)
      expect(encrypted).to_not(eq(message))
      decrypted = crypt.de(encrypted)
      expect(decrypted).to(eq(message))
    }
  }

  it('raises error if no secret provided') {
    expect { Tony::Utils::Crypt.new }.to(raise_error(ArgumentError))
  }

  it('raises error if secret is too short') {
    expect { Tony::Utils::Crypt.new('foobar') }.to(raise_error(ArgumentError))
  }
}
