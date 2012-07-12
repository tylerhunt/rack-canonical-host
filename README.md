# Rack Canonical Host

Rack middleware that lets you define a single host name as the canonical host
for your application. Requests for other host names will then be redirected to
the canonical host.

[![Build Status][travis-image]][travis]

[travis]: http://travis-ci.org/tylerhunt/rack-canonical-host
[travis-image]: https://secure.travis-ci.org/tylerhunt/rack-canonical-host.png


## Installation

Add this line to your application's `Gemfile`:

``` ruby
gem 'rack-canonical-host'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-canonical-host


## Usage

For most applications, you can insert the middleware into the `config.ru` file
in the root of the application.

Here's a simple example of what the `config.ru` in a Rails application might
look like after adding the `Rack::CanonicalHost` middleware.

``` ruby
require ::File.expand_path('../config/environment',  __FILE__)

use Rack::CanonicalHost, 'example.com'
run YourRailsApp::Application
```

In this case, any requests coming in that aren't for the specified host,
`example.com`, will be redirected, keeping the requested path intact.


### Environment-Specific Configuration

You probably don't want your redirect to happen when developing locally. One
way to prevent this from happening is to use environment variables in your
production environment to set the canonical host name.

With Heroku, you would do this like so:

    $ heroku config:add CANONICAL_HOST=example.com

Then, can configure the middleware like this:

``` ruby
use Rack::CanonicalHost, ENV['CANONICAL_HOST'] if ENV['CANONICAL_HOST']
```

Now, the middleware will only be used if a canonical host has been defined.


### Options

If you'd like the middleware to ignore certain hosts, use the `:ignore`
option:

``` ruby
use Rack::CanonicalHost, 'example.com', ignore: ['api.example.com']
```

In this case, requests for the host `api.example.com` will not be redirected.

Alternatively, you can pass a block whose return value will be used as the
canonical host name.

``` ruby
use Rack::CanonicalHost do
  case ENV['RACK_ENV'].to_sym
    when :staging then 'staging.example.com'
    when :production then 'example.com'
  end
end
```


## Contributing

  1. Fork it
  2. Create your feature branch (`git checkout -b my-new-feature`)
  3. Commit your changes (`git commit -am 'Add some feature.'`)
  4. Push to the branch (`git push origin my-new-feature`)
  5. Create a new Pull Request


## Contributors

Thanks to the following people who have contributed patches or helpful
suggestions:

  * [Peter Baker](https://github.com/finack)
  * [Jon Wood](https://github.com/jellybob)
  * [Nathaniel Bibler](https://github.com/nbibler)
  * [Eric Allam](https://github.com/rubymaverick)
  * [Fabrizio Regini](https://github.com/freegenie)


## Copyright

Copyright © 2009-2012 Tyler Hunt.
Released under the terms of the MIT license. See LICENSE for details.
