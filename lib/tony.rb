Dir.glob('**/*.rb').each { |file|
  require_relative file
}
