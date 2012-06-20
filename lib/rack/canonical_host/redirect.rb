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
        @options = options
      end

      def known_host?
        request_host == @host || ignored_host?
      end

      def response
        [
          301,
          { 'Location' => url, 'Content-Type' => 'text/html' },
          [HTML_TEMPLATE % url]
        ]
      end

      def request_host
        @request_host ||= @env['SERVER_NAME']
      end
      private :request_host

      def ignored_host?
        if ignored_hosts = @options[:ignored_hosts]
          ignored_hosts.include?(request_host)
        end
      end
      private :ignored_host?

      def url
        url = Rack::Request.new(@env).url
        url.sub(%r{\A(https?://)(.*?)(:\d+)?(/|$)}, "\\1#{@host}\\3/")
      end
      private :url
    end
  end
end
