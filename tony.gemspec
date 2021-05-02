Gem::Specification.new do |spec|
  spec.name          = 'tony'
  spec.version       = '0.11'
  spec.summary       = %q(Tony Bennett is way better than Sinatra.)
  spec.authors       = ['Justin Bishop']
  spec.email         = ['jubishop@gmail.com']
  spec.homepage      = 'https://github.com/jubishop/tony'
  spec.license       = 'MIT'
  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.metadata      = {
    'source_code_uri' => 'https://github.com/jubishop/tony'
  }
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0')
  spec.add_runtime_dependency('base64')
  spec.add_runtime_dependency('rack')
  spec.add_runtime_dependency('rack-contrib')
end
