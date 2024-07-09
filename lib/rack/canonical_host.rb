require 'rack'
require 'rack/canonical_host/redirect'
require 'rack/canonical_host/request'
require 'rack/canonical_host/version'

module Rack
  class CanonicalHost
    def initialize(app, host=nil, options={}, &block)
      self.app = app
      self.host = host
      self.options = options
      self.block = block
    end

    def call(env)
      request = Request.new(env)

      return request.bad_request_response unless request.valid?

      redirect = Redirect.new(env, host, options, &block)

      if redirect.canonical?
        app.call(env)
      else
        redirect.response
      end
    end

  protected

    attr_accessor :app
    attr_accessor :host
    attr_accessor :options
    attr_accessor :block
  end
end
