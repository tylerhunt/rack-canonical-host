require 'rack'
require 'rack/canonical_host/redirect'
require 'rack/canonical_host/version'

module Rack
  class CanonicalHost
    def initialize(app, host=nil, options={}, &block)
      @app = app
      @host = host
      @options = options
      @block = block
    end

    def call(env)
      host = host(env)
      redirect = Redirect.new(env, host, @options)

      if redirect.canonical?
        @app.call(env)
      else
        redirect.response
      end
    end

  private

    def host(env)
      @block ? @block.call(env) || @host : @host
    end
  end
end
