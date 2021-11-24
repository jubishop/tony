module Tony
  module Log
    def info(msg)
      return if ENV.fetch('APP_ENV') == 'production'

      puts msg
    end
  end
end
