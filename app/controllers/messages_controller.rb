class MessagesController < ActionController

  def reply
    message_body = params["Body"]
    from_number = params["From"]
    twilio_phone_number = '2164782291'
    boot_twilio
    sms = @client.messages.create(
      from: twilio_phone_number,
      to: from_number,
      body: "Hello there, thanks for texting me. Your number is #{from_number}."
    )
    
  end
 
  private
 
  def boot_twilio
    twilio_sid = ENV['TWILIO_ACCOUNT_SID']
    twilio_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new twilio_sid, twilio_token
  end
end