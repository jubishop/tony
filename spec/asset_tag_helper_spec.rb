RSpec.describe(Tony::AssetTagHelper) {
  include Tony::AssetTagHelper
  let(:public_folder) { 'spec/assets' }

  def tight(string)
    return string.gsub(/\s+/, ' ').strip
  end

  context('in development env') {
    before(:each) {
      allow(Time).to(receive(:now)).and_return(99)
    }

    it('creates a favicon tag') {
      expect(tight(favicon_link_tag)).to(eq(tight(<<~HTML)))
        <link rel="icon"
              href="/favicon.ico?v=99" />
      HTML
    }

    it('creates an image tag') {
      tag = image_tag('tony.jpg', alt: 'hello')
      expect(tight(tag)).to(eq(tight(<<~HTML)))
        <img src="/tony.jpg?v=99"
              alt="hello" />
      HTML
    }

    it('creates a stylesheet link tag') {
      tag = stylesheet_link_tag(:test)
      expect(tight(tag)).to(eq(tight(<<~HTML)))
        <link rel="stylesheet"
              href="/test.css?v=99"
              media="screen" />
      HTML
    }

    it('creates a javascript include tag') {
      tag = javascript_include_tag(:test)
      expect(tight(tag)).to(eq(tight(<<~HTML)))
        <script src="/test.js?v=99"
                crossorigin="anonymous"></script>
      HTML
    }
  }

  context('external site tags') {
    it('creates an external stylesheet link tag') {
      tag = stylesheet_link_tag('http://jubishop.com/style.css')
      expect(tight(tag)).to(eq(tight(<<~HTML)))
        <link rel="stylesheet"
              href="http://jubishop.com/style.css"
              media="screen" />
      HTML
    }

    it('creates an external javascript include tag') {
      tag = javascript_include_tag('http://jubishop.com/script.js')
      expect(tight(tag)).to(eq(tight(<<~HTML)))
        <script src="http://jubishop.com/script.js"
                crossorigin="anonymous"></script>
      HTML
    }
  }

  context('env agnostic') {
    it('creates a preconnect link tag') {
      expect(tight(preconnect_link_tag('source'))).to(eq(tight(<<~HTML)))
        <link rel="preconnect"
              href="source"
              crossorigin />
      HTML
    }

    it('includes google fonts') {
      tag = google_fonts('Fira Sans', 'Fira Code')
      expect(tight(tag)).to(eq(tight(<<~HTML)))
        <link rel="preconnect"
              href="https://fonts.gstatic.com"
              crossorigin />
        <link rel="stylesheet"
              href="https://fonts.googleapis.com/css2?family=Fira Sans&family=Fira Code&display=swap"
              media="screen" />
      HTML
    }

    it('includes fontawesome kits') {
      tag = font_awesome('kit123')
      expect(tight(tag)).to(eq(tight(<<~HTML)))
        <script src="https://kit.fontawesome.com/kit123.js"
                crossorigin="anonymous"></script>
      HTML
    }
  }

  context('in production env') {
    before(:each) {
      ENV['APP_ENV'] = 'production'
    }

    it('creates a favicon tag') {
      mtime = File.mtime('spec/assets/favicon.ico').to_i
      expect(tight(favicon_link_tag)).to(eq(tight(<<~HTML)))
        <link rel="icon"
              href="/favicon.ico?v=#{mtime}" />
      HTML
    }

    it('creates an image tag') {
      mtime = File.mtime('spec/assets/tony.jpg').to_i
      tag = image_tag('tony.jpg', alt: 'hello')
      expect(tight(tag)).to(eq(tight(<<~HTML)))
        <img src="/tony.jpg?v=#{mtime}"
              alt="hello" />
      HTML
    }

    it('creates a stylesheet link tag') {
      mtime = File.mtime('spec/assets/test.css').to_i
      tag = stylesheet_link_tag(:test)
      expect(tight(tag)).to(eq(tight(<<~HTML)))
        <link rel="stylesheet"
              href="/test.css?v=#{mtime}"
              media="screen" />
      HTML
    }

    it('creates a javascript include tag') {
      mtime = File.mtime('spec/assets/test.js').to_i
      tag = javascript_include_tag(:test)
      expect(tight(tag)).to(eq(tight(<<~HTML)))
        <script src="/test.js?v=#{mtime}"
                crossorigin="anonymous"></script>
      HTML
    }
  }
}
