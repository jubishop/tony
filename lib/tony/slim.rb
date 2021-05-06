require 'slim'

module Tony
  class Slim
    def initialize(views:, layout: nil)
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

    module ContentFor
      def content_for(key)
        content_blocks[key.to_sym].push(yield)
        return
      end

      def yield_content(key)
        content_blocks[key.to_sym].join
      end

      private

      def content_blocks
        @content_blocks ||= Hash.new { |hash, key| hash[key] = [] }
      end
    end

    class Env
      include Tony::AssetTagHelper
      include ContentFor

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
