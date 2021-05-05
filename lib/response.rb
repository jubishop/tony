require 'rack'
require 'slim'

require_relative 'asset_tag_helper'

module Tony
  class Response < Rack::Response
    undef :body= # use write()

    attr_accessor :error

    def initialize(layout = nil, **options)
      super()
      @layout = layout
      @options = options
    end

    def finish
      headers.transform_keys!(&:to_s)
      self.content_type ||= 'text/html;charset=utf-8'
      return super
    end

    def set_cookie(key, value)
      super(key, crypt.en(value))
    end

    def render(file, **locals)
      file = File.join(@options[:views], "#{file}.slim")
      env = SlimEnv.new(**locals)
      write(@layout.render(env) { Slim::Template.new(file).render(env) })
    end

    private

    def crypt
      return @crypt ||= Utils::Crypt.new(@options.fetch(:secret))
    end

    class SlimEnv
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
