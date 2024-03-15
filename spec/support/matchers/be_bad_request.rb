module BadRequest
  class Matcher
    def matches?(response)
      status_code, _, _ = response

      status_code_matches?(status_code)
    end

    def description
      'be a bad request'
    end

    def failure_message
      "Expected response to #{description}"
    end

    def failure_message_when_negated
      "Did not expect response to #{description}"
    end

  protected

    attr_accessor :actual_status_code

  private

    STATUS = 400

    def status_code_matches?(actual_status_code)
      STATUS == actual_status_code
    end
  end

  def be_bad_request
    Matcher.new
  end
end

RSpec.configure do |config|
  config.include BadRequest
end
