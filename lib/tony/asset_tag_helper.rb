module Tony
  module AssetTagHelper
    def favicon_link_tag(source = :favicon, rel: :icon)
      %(<link rel="#{rel}"
              href="#{Private.static_url(self, source, 'ico')}" />)
    end

    def preconnect_link_tag(source)
      %(<link rel="preconnect"
              href="#{source}"
              crossorigin />)
    end

    def image_tag(source, alt:)
      %(<img src="#{Private.static_url(self, source)}"
             alt="#{alt}" />)
    end

    def stylesheet_link_tag(source, media: :screen)
      %(<link rel="stylesheet"
              href="#{Private.static_url(self, source, 'css')}"
              media="#{media}" />)
    end

    def javascript_include_tag(source, crossorigin: :anonymous)
      %(<script src="#{Private.static_url(self, source, 'js')}"
                crossorigin="#{crossorigin}"></script>)
    end

    def google_fonts(*fonts)
      families = fonts.map { |font| "family=#{font}" }.join('&')
      source = "https://fonts.googleapis.com/css2?#{families}&display=swap"
      <<~HTML
        #{preconnect_link_tag('https://fonts.gstatic.com')}
        #{stylesheet_link_tag(source)}
      HTML
    end

    def font_awesome(kit_id)
      javascript_include_tag("https://kit.fontawesome.com/#{kit_id}.js",
                             crossorigin: :anonymous)
    end

    module Private
      @mtimes = {}
      class << self
        private

        def time(app, source)
          return Time.now.to_i unless ENV.fetch('APP_ENV') == 'production'

          unless @mtimes.key?(source)
            @mtimes[source] = File.mtime(static_path(app, source)).to_i
          end

          return @mtimes.fetch(source)
        end

        def static_path(app, source)
          public_folder = if app.respond_to?(:public_folder)
                            app.public_folder
                          else
                            'public'
                          end
          return File.join(public_folder, source)
        end
      end

      def self.static_url(app, source, ext = nil)
        source = source.to_s
        return source if source.start_with?('http')

        source.prepend('/') unless source.start_with?('/')
        source += ".#{ext}" if ext
        return "#{source}?v=#{time(app, source)}"
      end
    end
  end
end
