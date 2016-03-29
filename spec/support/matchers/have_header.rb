module HaveHeader
  class Matcher
    attr :headers
    attr :expected_header
    attr :expected_value

    def initialize(expected_header)
      @expected_header = expected_header
    end

    def matches?(response)
      _, @headers, _ = response

      if expected_value
        actual_header == expected_value
      else
        actual_header
      end
    end

    def with(expected_value)
      @expected_value = expected_value
      self
    end

    def actual_header
      headers[expected_header]
    end

    def description
      sentence = "have header #{expected_header.inspect}"
      sentence << " with #{expected_value.inspect}" if expected_value
      sentence << ", got:\n #{headers.inspect}"
    end

    def failure_message
      "Expected response to #{description}"
    end

    def failure_message_when_negated
      "Did not expect response to #{description}"
    end
  end

  def have_header(name)
    Matcher.new(name)
  end
end

RSpec.configure do |config|
  config.include(HaveHeader)
end
