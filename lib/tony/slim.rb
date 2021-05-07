require 'slim'

module Tony
  class Slim
    def initialize(views: 'views', layout: nil)
      @views = views
      @layout = if layout
                  ::Slim::Template.new("#{layout}.slim")
                else
                  ::Slim::Template.new { '==yield' }
                end
    end

    def render(file, **locals)
      file = File.join(@views, "#{file}.slim")
      env = Env.new(**locals)
      view = ::Slim::Template.new(file).render(env)
      return @layout.render(env) { view }
    end

    class Env
      include Tony::AssetTagHelper
      include Tony::ContentFor

      def initialize(**locals)
        @locals = locals
      end

      def method_missing(method, *args, &block)
        return @locals.key?(method) ? @locals.fetch(method) : super
      end

      def respond_to_missing?(method, include_all)
        return @locals.key?(method) || super
      end
    end
  end
end
