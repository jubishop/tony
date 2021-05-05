RSpec.describe(Tony::Response) {
  include Capybara::RSpecMatchers

  it('does not allow writing to body') {
    resp = Tony::Response.new
    expect { resp.body = 'Hello World' }.to(raise_error(NoMethodError))
  }

  it('holds an error') {
    resp = Tony::Response.new
    resp.error = Exception.new('Hello World')
    expect(resp.error.message).to(eq('Hello World'))
  }

  context('rendering slim views in basic layout') {
    before(:each) {
      @template = Slim::Template.new('spec/assets/views/layouts/basic.slim')
      @resp = Tony::Response.new(@template, views: 'spec/assets/views')
    }

    it('renders a basic view') {
      expect(@resp.render(:basic)).to(have_selector('p', text: 'Hello World'))
    }

    it('renders asset tag helpers') {
      allow(Time).to(receive(:now)).and_return(99)
      expect(@resp.render(:tag_helpers)).to(
          have_selector('link[href="/main.css?v=99"]'))
    }

    it('renders local variables') {
      expect(@resp.render(:locals, name: 'Tony')).to(have_content('Tony'))
    }
  }

  context('rendering basic views in layouts') {
    def response(layout)
      template = Slim::Template.new(
          File.join('spec/assets/views/layouts', layout))
      return Tony::Response.new(template, views: 'spec/assets/views')
    end

    it('renders asset tag helpers') {
      allow(Time).to(receive(:now)).and_return(99)
      resp = response('tag_helpers.slim')
      expect(resp.render(:basic)).to(
          have_selector('link[href="/layout.css?v=99"]'))
    }

    it('renders local variables') {
      allow(Time).to(receive(:now)).and_return(99)
      resp = response('locals.slim')
      expect(resp.render(:basic, name: 'Bennett')).to(
          have_content('Mr Bennett'))
    }
  }
}
