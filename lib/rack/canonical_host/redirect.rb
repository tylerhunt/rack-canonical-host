require 'addressable/uri'
require 'rack'

module Rack
  class CanonicalHost
    class Redirect
      DEFAULT_CACHE_EXPIRY_IN_SECONDS = 3600

      HTML_TEMPLATE = <<-HTML.gsub(/^\s+/, '')
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
        self.env = env
        self.host = host
        self.ignore = Array(options[:ignore])
        self.conditions = Array(options[:if])

        if options.has_key?(:cache_expiry)
          self.cache_expiry = options[:cache_expiry]
        else
          self.cache_expiry = DEFAULT_CACHE_EXPIRY_IN_SECONDS
        end
      end

      def canonical?
        return true unless enabled?
        known? || ignored?
      end

      def response
        [301, headers, [HTML_TEMPLATE % new_url]]
      end

    protected

      attr_accessor :env
      attr_accessor :host
      attr_accessor :ignore
      attr_accessor :conditions
      attr_accessor :cache_expiry

    private

      def any_match?(patterns, string)
        patterns.any? { |pattern| string[pattern] }
      end

      def headers
        {
          'Location' => new_url,
          'Content-Type' => 'text/html'
        }.merge(cache_control_headers)
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

      private

      def cache_control_headers
        cache_expiry ? { 'Cache-Control' => cache_control_value } : {}
      end

      def cache_control_value
        cache_expiry.is_a?(Fixnum) ? "max-age=#{cache_expiry}" : cache_expiry
      end
    end
  end
end
