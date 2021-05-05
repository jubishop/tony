RSpec.describe(Tony::Response) {
  it('does not allow writing to body') {
    resp = Tony::Response.new
    expect { resp.body = 'Hello World' }.to(raise_error(NoMethodError))
  }

  it('holds an error') {
    resp = Tony::Response.new
    resp.error = Exception.new('Hello World')
    expect(resp.error.message).to(eq('Hello World'))
  }
}
