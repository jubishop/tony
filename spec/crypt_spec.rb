require_relative '../lib/crypt'

RSpec.describe(Tony::Crypt) {
  it('encrypts and decrypts to the same thing') {
    crypt = Tony::Crypt.instance('test secret')
    expect(crypt.de(crypt.en('hello'))).to(eq('hello'))
  }
}
