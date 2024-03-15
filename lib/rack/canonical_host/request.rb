require 'addressable/uri'
require 'rack'

module Rack
  class CanonicalHost
    class Request
      BAD_REQUEST = <<-HTML.gsub(/^\s+/, '')
        <!DOCTYPE html>
        <html lang="en-US">
          <head><title>400 Bad Request</title></head>
          <body>
            <h1>Bad Request</h1>
          </body>
        </html>
      HTML

      def initialize(env)
        self.env = env
      end

      def valid?
        Addressable::URI.parse(Rack::Request.new(env).url)
        true
      rescue Addressable::URI::InvalidURIError
        false
      end

      def bad_request_response
        [400, { 'content-type' => 'text/html' }, [BAD_REQUEST]]
      end

    protected

      attr_accessor :env
    end
  end
end
