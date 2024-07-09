require 'addressable/uri'
require 'rack'

module Rack
  class CanonicalHost
    class Redirect
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

      def initialize(env, host, options={}, &block)
        self.env = env
        self.host = host
        self.ignore = Array(options[:ignore])
        self.conditions = Array(options[:if])
        self.cache_control = options[:cache_control]
        self.block = block
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
      attr_accessor :cache_control
      attr_accessor :block

    private

      def any_match?(patterns, request_uri)
        patterns.any? { |pattern|
          case pattern
          when Proc   then pattern.call(request_uri)
          when Regexp then request_uri.host =~ pattern
          when String then request_uri.host == pattern
          else false
          end
        }
      end

      def headers
        {
          'cache-control' => cache_control,
          'content-type' => 'text/html',
          'location' => new_url,
        }.reject { |_, value| !value }
      end

      def enabled?
        return true if conditions.empty?

        any_match?(conditions, request_uri)
      end

      def ignored?
        return false if ignore.empty?

        any_match?(ignore, request_uri)
      end

      def known?
        evaluated_host.nil? || request_uri.host == evaluated_host
      end

      def new_url
        uri = request_uri.dup
        uri.host = evaluated_host
        uri.normalize.to_s
      end

      def evaluated_host
        @evaluated_host ||= block and block.call(env) or host
      end

      def request_uri
        @request_uri ||= Addressable::URI.parse(Rack::Request.new(env).url)
      end
    end
  end
end
