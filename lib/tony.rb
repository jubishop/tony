Dir.glob("#{File.dirname(__FILE__)}/**/*.rb").each { |file|
  require_relative file unless file == __FILE__
}
