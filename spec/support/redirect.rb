module Redirect
  class Matcher
    attr_reader :expected_status_code
    attr_reader :expected_location
    attr_reader :response
    attr_reader :status_code
    attr_reader :location

    def matches?(response)
      @response = response
      @status_code = @response.to_a.first
      @location = @response.to_a[1]['Location']

      status_code_matches? && location_matches?
    end

    def via(expected_status_code)
      @expected_status_code = expected_status_code
      self
    end

    def to(expected_location)
      @expected_location = expected_location
      self
    end

    def description
      case
      when expected_status_code && expected_location
        "return a #{expected_status_code} to \"#{expected_location}\" response"
      when expected_status_code
        "return a #{expected_status_code} status response"
      when expected_location
        "return a Location header containing \"#{expected_location}\""
      else
        "return a redirection response"
      end
    end

    def failure_message_for_should
      case
      when expected_status_code && !status_code_matches?
        "expected #{status_code} to be #{expected_status_code}"
      when expected_location && !location_matches?
        "expected #{location.inspect} to be \"#{expected_location}\""
      else
        "expected #{status_code} to be a redirection code (301, 302, 303, 307)"
      end
    end

    def failure_message_for_should_not
      case
      when expected_status_code && status_code_matches?
        "expected #{status_code} to not be #{expected_status_code}"
      when expected_location && location_matches?
        "expected #{location.inspect} to not be \"#{expected_location}\""
      else
        "expected #{status_code} to not be a redirection code (301, 302, 303, 307)"
      end
    end


    private


    def status_code_matches?
      if expected_status_code
        expected_status_code == status_code
      else
        status_code.to_s =~ /^30[1237]$/
      end
    end

    def location_matches?
      !expected_location || (expected_location == location)
    end
  end

  def redirect
    Matcher.new
  end
end

RSpec.configure do |config|
  config.include(Redirect)
end
