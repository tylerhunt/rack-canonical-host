require 'addressable/uri'
require 'rack'

module Rack
  class CanonicalHost
    class Redirect
      PERMANENT_TEMPLATE = <<-HTML.gsub(/^\s+/, '')
        <!DOCTYPE html>
        <html lang="en-US">
          <head><title>301 Moved Permanently</title></head>
          <body>
            <h1>Moved Permanently</h1>
            <p>The document has moved <a href="%s">here</a>.</p>
          </body>
        </html>
      HTML

      TEMPORARY_TEMPLATE = <<-HTML.gsub(/^\s+/, '')
        <!DOCTYPE html>
        <html lang="en-US">
          <head><title>307 Temporary Redirect</title></head>
          <body>
            <h1>Moved Temporarily</h1>
            <p>The document has temporarily moved <a href="%s">here</a>.</p>
          </body>
        </html>
      HTML

      def initialize(env, host, options={})
        self.env = env
        self.host = host
        self.ignore = Array(options[:ignore])
        self.conditions = Array(options[:if])
        self.cache_control = options[:cache_control]
        self.prefix = options[:prefix]
        self.temporary = !!options[:temporary]
        if prefix
          self.separator =
            case options[:separator]
            when String
              (options[:separator] =~ /%/) ?
                options[:separator]        :
                Addressable::URI.encode(options[:separator])
            else
              Addressable::URI::SLASH
            end
        end
        self.append = !!options[:append]
      end

      def canonical?
        return true unless enabled?
        known? || ignored?
      end

      def response
        temporary ? temporary_response : permanent_response
      end

    protected

      attr_accessor :env
      attr_accessor :host
      attr_accessor :ignore
      attr_accessor :conditions
      attr_accessor :cache_control
      attr_accessor :temporary
      attr_accessor :prefix
      attr_accessor :separator
      attr_accessor :append

    private

      def permanent_response
        [301, headers, [PERMANENT_TEMPLATE % new_url]]
      end

      def temporary_response
        [307, headers, [TEMPORARY_TEMPLATE % new_url]]
      end

      def any_match?(patterns, host)
        patterns.any? { |pattern|
          case pattern
          when Regexp then host =~ pattern
          when String then host == pattern
          else false
          end
        }
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

        any_match?(conditions, request_uri.host)
      end

      def ignored?
        return false if ignore.empty?

        any_match?(ignore, request_uri.host)
      end

      def known?
        host.nil? || request_uri.host == host
      end

      def new_url
        uri = request_uri.dup
        uri.host = host

        add_prefix(uri) if self.prefix
        append_domain(uri) if self.append

        uri.normalize.to_s
      end

      def add_prefix(uri)
        case prefix
        when true, :subdomain
          uri.path = join_path(subdomain, uri.path)
        when :bottom_to_top
          uri.path = join_path(subdomain(true), uri.path)
        when String
          uri.path = join_path(prefix, uri.path)
        end
      end

      def append_domain(uri)
        query_params = uri.query_values
        query_params['original_host'] = request_uri.hostname
        uri.query_values = query_params
      end

      def join_path(first, second)
        [
          *first.to_s.split(Addressable::URI::SLASH),
          *second.to_s.split(Addressable::URI::SLASH)
        ].
          select {|v| !v.empty? }.
          join(Addressable::URI::SLASH)
      end

      def request_uri
        @request_uri ||= Addressable::URI.parse(Rack::Request.new(env).url)
      end

      def subdomain(bottom_to_top = false)
        @split_domain ||=
          request_uri.hostname&.
            sub(request_uri.domain, '')&.
            chomp('.')&.
            split('.')

        (
          bottom_to_top ?
          @split_domain :
          @split_domain&.reverse
        )&.
          join(self.separator)
      end
    end
  end
end
