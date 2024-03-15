require 'rack'
require 'rack/canonical_host/redirect'
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
      host = evaluate_host(env)
      redirect = Redirect.new(env, host, options)

      begin
        return redirect.response unless redirect.canonical?
      rescue Addressable::URI::InvalidURIError
        return [400, { Rack::CONTENT_TYPE => "text/plain", Rack::CONTENT_LENGTH => "0" }, []]
      end

      app.call(env)
    end

  protected

    attr_accessor :app
    attr_accessor :host
    attr_accessor :options
    attr_accessor :block

  private

    def evaluate_host(env)
      block and block.call(env) or host
    end
  end
end
