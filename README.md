# tony

[![RSpec Status](https://github.com/jubishop/tony/workflows/RSpec/badge.svg)](https://github.com/jubishop/tony/actions/workflows/rspec.yml)  [![Rubocop Status](https://github.com/jubishop/tony/workflows/Rubocop/badge.svg)](https://github.com/jubishop/tony/actions/workflows/rubocop.yml)

A focused and straightforward Ruby web framework.

## Installation

### In a Gemfile

```ruby
source: 'https://www.jubigems.org/'
  gem 'core'
  gem 'tony'
end
```

## Guiding Principles

### Understandable.

`Tony` is tiny.  There is no excessive metaprogramming or syntactical shenanigans.  You can read the code and understand it.  Magical constructs can make `Hello World` examples look beautiful, but become increasingly problematic as your program scales in complexity.

### Composition over inheritance.

`Tony` encourages a design pattern of composing small and highly targeted utilities rather than inheriting from one mammoth kitchen-sink base class.  No single file is more than 100 lines, and each class has a specific, singular purpose.

### Fast and inherently thread safe.

`Tony` follows the elegant design principles of Rack.  A `Tony` app is one instance that is frozen after initialization.  Everything regarding a single request happens inside the `call()` method.  This makes `Tony` inherently fast and thread safe.

### One way to do things.

We all love the flexibility and expressiveness of Ruby.  But when there's just one way to do something, the library code remains simpler and developers moving from one project to another can easily understand what's happening.

### Use what exists.

Many excellent Rack middlewares and Ruby language features already exist, and there's no reason for `Tony` to reinvent those wheels.

## Hello World

In a `config.ru` file:

```ruby
require 'tony'

app = Tony.new
app.get('/', ->(_, resp) {
  resp.write('Hello World')
})

run app
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
