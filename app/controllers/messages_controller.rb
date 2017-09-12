class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def reply
    message_body = params["Body"]
    from_number = params["From"]
    twilio_phone_number = '2164782291'
    twilio_sid = 'ACf92fbc0df0473fba6673a485c2d3cf9c'
    twilio_token = '1fbdc1437c16d0df71e8dd6c48beab33'
    @client = Twilio::REST::Client.new twilio_sid, twilio_token
    sms = @client.api.account.messages.create(
      from: "+1#{twilio_phone_number}",
      to: from_number,
      body: "Happy Tuesday!! Your number is #{from_number}."
    )
    
  end
 
  private
 
  def boot_twilio
    twilio_sid = ENV['TWILIO_ACCOUNT_SID']
    twilio_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new twilio_sid, twilio_token
  end
end