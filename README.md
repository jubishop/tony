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

### Understandable

`Tony` is tiny.  There is no excessive metaprogramming or syntactical shenanigans.  You can read the code and understand it.  Magical constructs can make `Hello World` examples look beautiful, but become increasingly problematic as your program scales in complexity.

### Composition over inheritance

`Tony` encourages a design pattern of composing small and highly targeted utilities rather than inheriting from one mammoth kitchen-sink base class.  No single file is more than 100 lines, and each class has a specific, singular purpose.

### Fast and inherently thread safe

`Tony` follows the elegant design principles of Rack.  A [`Tony`](https://github.com/jubishop/tony/blob/master/lib/tony/app.rb) app is one instance that is frozen after initialization.  Everything regarding a single request happens inside the `call()` method.  This makes `Tony` inherently fast and thread safe.

### One way to do things

We all love the flexibility and expressiveness of Ruby.  But when there's just one way to do something, the library code remains simpler and developers moving from one project to another can easily understand what's happening.

### Use what exists

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

## Routing

`Tony` routes paths to lambdas and passes them two parameters: a [`Tony::Request`](https://github.com/jubishop/tony/blob/master/lib/tony/request.rb) and a [`Tony::Response`](https://github.com/jubishop/tony/blob/master/lib/tony/response.rb).  These classes extend [`Rack::Request`](https://github.com/rack/rack/blob/master/lib/rack/request.rb) and [`Rack::Response`](https://github.com/rack/rack/blob/master/lib/rack/response.rb) respectively.  A simple route can be created for exact matches with a `String`, but you can also pass a [`Regexp`](https://ruby-doc.org/core/Regexp.html) and any [`named_captures`](https://ruby-doc.org/core/Regexp.html#method-i-named_captures) are appended to the `.params` `Hash` inside the [`Tony::Response`](https://github.com/jubishop/tony/blob/master/lib/tony/response.rb):

```ruby
require 'tony'

app = Tony.new
# This would capture, say: /Tony_Bennett/Life_Is_Beautiful
app.get(%r{^/(?<artist>.+?)/(?<album>.+)$}, ->(req, resp) {
  resp.write("Artist/Album: #{req.params[:artist]}/#{req.params[:album]}")
})

app.post('/save', ->(req, resp) {
  # Save something here, using values in the `req.params` Hash.
  resp.status = 201
  resp.write('Save successful')
}

run app
```

### Not Found

If no path matches, `Tony` will call the `not_found` block if it exists.

```ruby
app.not_found(->(req, resp) {
  # Status will default to 404 unless you set it yourself.
  resp.write("Sorry, #{req.url} is not a valid url")
})
```

### Catching Errors

If any call raises an Error, `Tony` catches it and will calls any block passed to `error()` if one exists, adding the caught error message as `.error` to the [`Tony::Response`](https://github.com/jubishop/tony/blob/master/lib/tony/response.rb) instance.  You might want to choose to display a friendly error message in production but raise the stack trace in development.  You could do something like:

```ruby
app.error(->(_, resp) {
  if env['APP_ENV'] == 'production'
    resp.status = 500
    resp.write('Sorry, an error has occurred')
  else
    raise resp.error
  end
})
```

### throw(:response)

Every call is wrapped in a `catch(:response)`, which means wherever you are in the stack, once you've filled in your [`Tony::Response`](https://github.com/jubishop/tony/blob/master/lib/tony/response.rb), you can call `throw(:response)` to immediately unwind the stack and respond:

```ruby
def level_three(resp)
  resp.write('Hello from down here!')
  throw(:response)
end

def level_two(resp)
  level_three(resp)
end

def level_one(resp)
  level_two(resp)
end

app.get('/deep_stack', ->(_, resp) {
  level_one(resp)
  resp.404 # this won't get called because of the throw(:response).
  resp.write('No response was found I guess')
})
```

## Encrypted Cookies

`Tony` provides strong `aes-256-cbc` encryption, you can see exactly how it works in [`crypt.rb`](https://github.com/jubishop/tony/blob/master/lib/tony/utils/crypt.rb).  Once you've passed a `:secret` param to your [`Tony`](https://github.com/jubishop/tony/blob/master/lib/tony/app.rb) instance, it will provide methods in the `Tony::Response` to set and encrypt cookies, and in `Tony::Request` to get and decrypt them.  If you don't pass a `:secret`, `Tony` will refuse to read or write cookies for you.  (Pro-tip:  Use [`SecureRandom`](https://ruby-doc.org/stdlib/libdoc/securerandom/rdoc/SecureRandom.html) to easily make yourself a strong secret.)

```ruby
app = Tony.new(secret: 'PLEASE_REPLACE_THIS')
app.post('/set_cookie', ->(_, resp) {
  resp.set_cookie('tony', 'bennett')
  resp.write('Ok I set a cookie for key: tony')
})

app.post('/get_cookie', ->(req, resp) {
  value = req.get_cookie('tony')
  resp.write("Ok the cookie value for tony is: #{value}") # bennett
})
```

### Secret rotation

`Tony` provides an easy way to rotate new secrets.  Simply pass `:old_secret` to your `Tony` instance for what you've been using, and `:secret` for what you want to rotate into.

```ruby
app = Tony.new(secret: 'FLY_ME_TO_THE_MOON', old_secret: 'FOR_ONCE_IN_MY_LIFE')
# Everything else works the same.
```

## Serving Static Files

`Tony` provides a static file server and an intelligent strategy for ensuring clients always cache files that haven't changed, but also always fetch them again once they have.

- It passes `'public, max-age=31536000, immutable'` for the `Cache-Control` header to tell a client to always cache what its fetched.
- It checks the `mtime` for each file (just once at launch, then it keeps the value in memory) and it appends that `mtime` to each asset url as part of a `?v=` parameter.

As soon as a file has been modified, the `mtime` will change and clients will fetch the new version.  But as long as it hasn't changed, clients will use the cached version for a year (31536000 seconds).

### Tony::Static

To utilize this functionality, first, add [`Tony::Static`](https://github.com/jubishop/tony/blob/master/lib/tony/static.rb) to your Rack `config.ru` file as a middleware, and optionally passing it the file location of all public assets (it defaults to the `public` folder)

```ruby
# In config.ru

require `tony`
use Tony::Static, public_folder: `my_public_folder`

# Now you'd create your `Tony::App` instance and `run` as in other examples.
```

### Asset Tag Helpers

Next, use the methods provided in [`AssetTagHelper`](https://github.com/jubishop/tony/blob/master/lib/tony/asset_tag_helper.rb) to create your asset tags for `CSS`, `Javascript` etc.  These will be covered in greater detail in the [`Slim`](https://github.com/jubishop/tony#slim) rendering section below.

## Rendering (Slim)


## Production Examples

- [JubiVote](https://github.com/jubishop/jubivote)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
