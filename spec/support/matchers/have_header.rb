module HaveHeader
  class Matcher
    def initialize(expected_header)
      self.expected_header = expected_header
    end

    def matches?(response)
      _, self.actual_headers, _ = response

      if expected_value
        actual_header == expected_value
      else
        actual_header
      end
    end

    def with(expected_value)
      self.expected_value = expected_value
      self
    end

    def description
      sentence = "have header #{expected_header.inspect}"
      sentence << " with #{expected_value.inspect}" if expected_value
      sentence
    end

    def failure_message
      "Expected response to #{description}"
    end

    def failure_message_when_negated
      "Did not expect response to #{description}"
    end

  protected

    attr_accessor :actual_headers
    attr_accessor :expected_header
    attr_accessor :expected_value

  private

    def actual_header
      actual_headers[expected_header]
    end
  end

  def have_header(name)
    Matcher.new(name)
  end
end

RSpec.configure do |config|
  config.include HaveHeader
end
