# Rack Canonical Host

Rack middleware that lets you define a single host name as the canonical host
for your application. Requests for other host names will then be redirected to
the canonical host.


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

If you'd like the middleware to ignore certain hosts, use the `:ignore_hosts`
option:

``` ruby
use Rack::CanonicalHost, 'example.com', ignored_hosts: ['api.example.com']
```

In this case, requests for the host `api.example.com` will not be redirected.

Alternatively, you can pass a block whose return value will be used as the
canonical host name.

``` ruby
use Rack::CanonicalHost do
  case ENV['RACK_ENV'].to_sym
    when :staging then 'example.com'
    when :production then 'staging.example.com'
  end
end
```


## Contributors

Thanks to the following people who have contributed patches or helpful
suggestions:

  * [Peter Baker](http://github.com/finack)
  * [Jon Wood](http://github.com/jellybob)
  * [Nathaniel Bibler](http://github.com/nbibler)
  * [Eric Allam](http://github.com/rubymaverick)


