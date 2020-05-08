module HaveQueryParams
  class Matcher
    def initialize(expected_params, exact:)
      self.expected_params = expected_params
      self.exact_match = !!exact
    end

    def matches?(response)
      _, self.actual_headers, _ = response

      params_match?
    end

    def description
      "#{exact_match ? 'equal' : 'contain'} #{expected_params.inspect}"
    end

    def failure_message
      "Expected response query params to #{description}, " \
      "received: #{actual_params.inspect}"
    end

    def failure_message_when_negated
      "Did not expect response query params to #{description}, " \
      "received: #{actual_params.inspect}"
    end

  protected

    attr_accessor :actual_headers
    attr_accessor :exact_match
    attr_accessor :expected_params

  private

    LOCATION = 'Location'

    def actual_location
      actual_headers[LOCATION]
    end

    def actual_params
      Rack::Utils.parse_query(actual_location.split('?')[1].to_s)
    end

    def params_match?
      keys = expected_params.keys
      keys |= actual_params.keys if exact_match
      keys.all? {|k| expected_params[k] == actual_params[k] }
    end
  end

  def have_query_params(location, exact: true)
    Matcher.new(location, exact: exact)
  end
end

RSpec.configure do |config|
  config.include HaveQueryParams
end
