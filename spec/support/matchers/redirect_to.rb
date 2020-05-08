module RedirectTo
  class Matcher
    def initialize(expected_location)
      self.expected_location = expected_location
      self.expected_status_code = STATUS
    end

    def matches?(response)
      self.actual_status_code, self.actual_headers, _ = response

      status_code_matches? && location_matches?
    end

    def via(expected_status_code)
      self.expected_status_code = expected_status_code
      self
    end

    def description
      if expected_status_code && expected_location
        "redirect to #{expected_location.inspect} via #{expected_status_code}"
      elsif expected_status_code
        "redirect via #{expected_status_code}"
      elsif expected_location
        "redirect to #{expected_location.inspect}"
      else
        'be a redirect'
      end
    end

    def failure_message
      "Expected response to #{description}, " \
      "received #{actual_location.inspect} via #{actual_status_code} instead"
    end

    def failure_message_when_negated
      "Did not expect response to #{description}"
    end

  protected

    attr_accessor :actual_headers
    attr_accessor :actual_status_code
    attr_accessor :expected_location
    attr_accessor :expected_status_code

  private

    LOCATION = 'Location'
    STATUS = 301

    def actual_location
      actual_headers[LOCATION]
    end

    def status_code_matches?
      if expected_status_code
        actual_status_code == expected_status_code
      else
        actual_status_code.to_s =~ /^30[1237]$/
      end
    end

    def location_matches?
      case expected_location
      when String then expected_location == actual_location
      when Regexp then actual_location =~ expected_location
      end
    end
  end

  def redirect_to(location)
    Matcher.new(location)
  end

  def be_redirect
    Matcher.new(nil).via(nil)
  end
end

RSpec.configure do |config|
  config.include RedirectTo
end
