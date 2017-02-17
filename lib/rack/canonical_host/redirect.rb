require 'addressable/uri'
require 'rack'

module Rack
  class CanonicalHost
    class Redirect
      HTML_TEMPLATE = <<-HTML.gsub(/^\s+/, '')
        <!DOCTYPE html>
        <html lang="en-US">
          <head><title>%{title}</title></head>
          <body>
            <h1>%{title}</h1>
            <p>The document has moved <a href="%{url}">here</a>.</p>
          </body>
        </html>
      HTML

      def initialize(env, host, options={})
        self.env = env
        self.host = host
        self.ignore = Array(options[:ignore])
        self.conditions = Array(options[:if])
        self.cache_control = options[:cache_control]
        @temporary = options[:temporary]
      end

      def canonical?
        return true unless enabled?
        known? || ignored?
      end

      def temporary?
        @temporary
      end

      def response
        [status, headers, [body]]
      end

    protected

      attr_accessor :env
      attr_accessor :host
      attr_accessor :ignore
      attr_accessor :conditions
      attr_accessor :cache_control

    private

      def status
        temporary? ? 302 : 301
      end

      def body
        HTML_TEMPLATE % { title: redirection_title, url: new_url }
      end

      def redirection_title
        "#{status} #{Rack::Utils::HTTP_STATUS_CODES[status]}"
      end

      def any_match?(patterns, string)
        patterns.any? { |pattern| string[pattern] }
      end

      def headers
        {
          'Cache-Control' => cache_control,
          'Content-Type' => 'text/html',
          'Location' => new_url,
        }.reject { |_, value| !value }
      end

      def enabled?
        return true if conditions.empty?

        conditions.include?(request_uri.host) ||
          any_match?(conditions, request_uri.host)
      end

      def ignored?
        ignore.include?(request_uri.host)
      end

      def known?
        host.nil? || request_uri.host == host
      end

      def new_url
        uri = request_uri.dup
        uri.host = host
        uri.normalize.to_s
      end

      def request_uri
        @request_uri ||= Addressable::URI.parse(Rack::Request.new(env).url)
      end
    end
  end
end
