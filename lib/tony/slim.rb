require 'slim'

module Tony
  class Slim
    attr_accessor :views, :layout

    def initialize(views: 'views',
                   layout: nil,
                   partials: 'views/partials',
                   options: {})
      @views = views
      @partials = partials
      @options = options
      @layout = if layout
                  ::Slim::Template.new("#{layout}.slim", @options)
                else
                  ::Slim::Template.new(@options) { '==yield' }
                end
    end

    def render(file, **locals)
      file = File.join(@views, "#{file}.slim")
      env = Env.new(partials: @partials, options: @options, **locals)
      view = ::Slim::Template.new(file, @options).render(env)
      return @layout.render(env) { view }
    end

    class Env
      include Tony::AssetTagHelper
      include Tony::ScriptHelper
      include Tony::ContentFor

      def initialize(partials:, options:, **locals)
        @partials = partials
        @options = options
        @locals = locals
      end

      def partial(file, **locals)
        file = File.join(@partials, "#{file}.slim")
        env = Env.new(partials: @partials,
                      options: @options,
                      **@locals.merge(locals))
        return ::Slim::Template.new(file, @options).render(env)
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
