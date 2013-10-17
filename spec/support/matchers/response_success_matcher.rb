RSpec::Matchers.define :be_successful do

  match do |response|
    response.error.nil?
  end

  failure_message_for_should do |response|
    "#{response} should be successful, got error(s): #{response.error.message}"
  end

  failure_message_for_should_not do |response|
    "#{response} should not be successful"
  end

end

RSpec::Matchers.define :fail do
  chain :with_message do |message|
    @message = message
  end

  match do |response|
    @failure = response.error

    if(@message)
      @failure && @failure.message == @message
    else
      @failure
    end

  end

  failure_message_for_should do |response|
    if(@message)
      "#{response} should have error message: #{@message}"
    else
      "#{response} should not be successful"
    end
  end

  failure_message_for_should_not do |response|
    "#{response} should be successful"
  end

end