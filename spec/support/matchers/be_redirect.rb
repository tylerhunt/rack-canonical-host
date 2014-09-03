module BeRedirect
  class Matcher
    attr :expected_status_code
    attr :expected_location
    attr :actual_status_code
    attr :actual_location

    def matches?(response)
      @actual_status_code, headers, _ = response
      @actual_location = headers['Location']

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
      if expected_status_code && expected_location
        "redirect via #{expected_status_code} to #{expected_location.inspect}"
      elsif expected_status_code
        "redirect via #{expected_status_code}"
      elsif expected_location
        "redirect to #{expected_location.inspect}"
      else
        "be a redirect"
      end
    end

    def failure_message
      "Expected response to #{description}"
    end

    def failure_message_when_negated
      "Did not expect response to #{description}"
    end

    def status_code_matches?
      if expected_status_code
        actual_status_code == expected_status_code
      else
        actual_status_code.to_s =~ /^30[1237]$/
      end
    end
    private :status_code_matches?

    def location_matches?
      !expected_location || (expected_location == actual_location)
    end
    private :location_matches?
  end

  def be_redirect
    Matcher.new
  end
end

RSpec.configure do |config|
  config.include(BeRedirect)
end
