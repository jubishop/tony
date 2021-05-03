require 'rack'

module Tony
  class Response < Rack::Response
    undef :body= # use write()

    def finish
      headers.transform_keys!(&:to_s)
      headers['Content-Type'] ||= 'text/html;charset=utf-8'
      return super
    end
  end
end
