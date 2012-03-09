module Rack # :nodoc:
  class CanonicalHost
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

    def initialize(app, host=nil, &block)
      @app = app
      @host = host
      @block = block
    end

    def call(env)
      if url = url(env)
        [
          301,
          { 'Location' => url, 'Content-Type' => 'text/html' },
          [HTML_TEMPLATE % url]
        ]
      else
        @app.call(env)
      end
    end

    def url(env)
      if (host = host(env))
        request = Rack::Request.new(env)
        if request.host != host
          request.url.sub(%r{\A(https?://)(.*?)(:\d+)?(/|$)}, "\\1#{host}\\3/")
        end
      end
    end
    private :url

    def host(env)
      @block ? @block.call(env) || @host : @host
    end
    private :host
  end
end
