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
  }
}
