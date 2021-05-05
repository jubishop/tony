require 'slim'

module Tony
  class Slim
    def initialize(views:, layout: nil)
      @views = views
      @layout = if layout
                  ::Slim::Template.new(layout)
                else
                  ::Slim::Template.new { '==yield' }
                end
    end

    def render(file, **locals)
      file = File.join(@views, "#{file}.slim")
      env = Env.new(**locals)
      return @layout.render(env) { ::Slim::Template.new(file).render(env) }
    end

    class Env
      include Tony::AssetTagHelper

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
