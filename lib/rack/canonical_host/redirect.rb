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
        @ignore = options[:ignore]
      end

      def canonical?
        known? || ignored?
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

      def new_url
        request_uri.tap { |uri| uri.host = @host }.to_s
      end
      private :new_url

      def request_uri
        URI.parse(Rack::Request.new(@env).url)
      end
      private :request_uri
    end
  end
end
