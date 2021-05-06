RSpec.describe(Tony::Slim) {
  include Capybara::RSpecMatchers

  before(:each) {
    allow(Time).to(receive(:now)).and_return(99)
  }

  context('rendering slim views in basic layout') {
    before(:each) {
      @slim = Tony::Slim.new(views: 'spec/assets/views',
                             layout: 'spec/assets/views/layouts/basic')
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
      return Tony::Slim.new(
          views: 'spec/assets/views',
          layout: File.join('spec/assets/views/layouts', layout))
    end

    it('renders asset tag helpers') {
      slim = renderer('tag_helpers')
      expect(slim.render(:basic)).to(
          have_selector('link[href="/layout.css?v=99"]'))
    }

    it('renders local variables') {
      slim = renderer('locals')
      expect(slim.render(:basic, name: 'Bennett')).to(
          have_content('Mr Bennett'))
    }
  }

  context('rendering views alone') {
    it('renders basic view with no layout') {
      slim = Tony::Slim.new(views: 'spec/assets/views')
      expect(slim.render(:basic)).to(have_selector('p', text: 'Hello World'))
    }
  }

  context('rendering content_for') {
    it('renders content_for correctly') {
      slim = Tony::Slim.new(
          views: 'spec/assets/views',
          layout: 'spec/assets/views/layouts/yield_content')
      expect(slim.render(:content_for)).to(have_content('Fly Me To The Moon'))
      expect(slim.render(:content_for)).to(have_content('You Look Tonight'))
      expect(slim.render(:content_for)).to_not(have_content('Once In My Life'))
    }
  }
}
