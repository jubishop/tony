RSpec.describe(Tony::View) {
  include Capybara::RSpecMatchers

  before(:each) {
    allow(Time).to(receive(:now)).and_return(99)
  }

  context('rendering slim views in basic layout') {
    before(:each) {
      @slim = Tony::View.new(views: 'spec/assets/views',
                             layout: 'spec/assets/views/layouts/basic.slim')
    }

    it('renders a basic view') {
      expect(@slim.render(:basic)).to(have_selector('p', text: 'Hello World'))
    }

    it('renders asset tag helpers') {
      expect(@slim.render(:tag_helpers)).to(
          have_selector('link[href="/main.css?v=99"]'))
    }

    it('renders local variables') {
      expect(@slim.render(:locals, name: 'Tony')).to(have_content('Tony'))
    }
  }

  context('rendering basic views in layouts') {
    def renderer(layout)
      return Tony::View.new(
          views: 'spec/assets/views',
          layout: File.join('spec/assets/views/layouts', layout))
    end

    it('renders asset tag helpers') {
      slim = renderer('tag_helpers.slim')
      expect(slim.render(:basic)).to(
          have_selector('link[href="/layout.css?v=99"]'))
    }

    it('renders local variables') {
      slim = renderer('locals.slim')
      expect(slim.render(:basic, name: 'Bennett')).to(
          have_content('Mr Bennett'))
    }
  }

  context('rendering views alone') {
    it('renders basic view with no layout') {
      slim = Tony::View.new(views: 'spec/assets/views')
      expect(slim.render(:basic)).to(have_selector('p', text: 'Hello World'))
    }
  }
}
