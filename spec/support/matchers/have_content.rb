module HaveContent
  class Matcher
    def initialize(expected_content)
      self.expected_content = expected_content
    end

    def matches?(response)
      self.actual_content = response.last.to_enum.next
      actual_content.include?(expected_content)
    end

    def description
      "the response to include #{expected_content.inspect}:\n" + actual_content
    end

    def failure_message
      "Expected #{description}"
    end

    def failure_message_when_negated
      "Did not expect #{description}"
    end

  protected

    attr_accessor :actual_content
    attr_accessor :expected_content

  end

  def have_content(expected)
    Matcher.new(expected)
  end
end

RSpec.configure do |config|
  config.include HaveContent
end
