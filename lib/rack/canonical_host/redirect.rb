require 'addressable/uri'

module Rack
  class CanonicalHost
    class Redirect
      HTML_TEMPLATE = <<-HTML
        <!DOCTYPE html>
        <html lang="en-US">
          <head><title>301 Moved Permanently</title></head>
          <body>
            <h1>Moved Permanently</h1>
            <p>The document has moved <a href="%s">here</a>.</p>
          </body>
        </html>
      HTML

      def initialize(env, host, options={})
        @env = env
        @host = host
        @ignore = Array(options[:ignore])
        @if = Array(options[:if])
      end

      def canonical?
          known? || ignored? || !conditions_match?
      end

      def response
        headers = { 'Location' => new_url, 'Content-Type' => 'text/html' }
        [301, headers, [HTML_TEMPLATE % new_url]]
      end

      def known?
        @host.nil? || request_uri.host == @host
      end
      private :known?

      def ignored?
        @ignore && @ignore.include?(request_uri.host)
      end
      private :ignored?

      def conditions_match?
        return true unless @if.size > 0
        @if.include?( request_uri.host ) || any_regexp_match?( @if, request_uri.host )
      end
      private :conditions_match?

      def any_regexp_match?( regexp_array, string )
        regexp_array.any?{ |r| string[r] }
      end
      private :any_regexp_match?

      def new_url
        request_uri.tap { |uri| uri.host = @host }.to_s
      end
      private :new_url

      def request_uri
        Addressable::URI.parse(Rack::Request.new(@env).url)
      end
      private :request_uri
    end
  end
end
