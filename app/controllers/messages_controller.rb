class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def reply
    message_body = params["Body"]
    from_number = params["From"]
    twilio_phone_number = '2164782291'
    twilio_sid = 'ACf92fbc0df0473fba6673a485c2d3cf9c'
    twilio_token = '1fbdc1437c16d0df71e8dd6c48beab33'
    languages = EasyTranslate::LANGUAGES.values
    translation = EasyTranslate.translate("#{message_body}", :to => :th, :key => 'AIzaSyBukYm7kIRpauOVu6eH7oA-plDDWlEuQBg')
    # languages = 
    #   EasyTranslate::LANGUAGES.values.each.with_index do |lang, i|
    #     puts "#{i+1}. #{lang}"
    #   end
    @client = Twilio::REST::Client.new twilio_sid, twilio_token
    if message_body == 'Hello'
      sms = @client.api.account.messages.create(
        from: "+1#{twilio_phone_number}",
        to: from_number,
        body: "Welcome to Chatbot!! Your number is #{from_number}.  Here are a list of lanaguages I'm fluent in:#{languages}.  What language do you prefer to text in?"
      )
    elsif message_body == 'Thai' || 'Spanish' || 'Japanese'  || 'German' || 'Greek' || 'Turkish' || 'English' || 'Afrikaans' || 'Albanian' || 'Arabic' || 'Belarusian' || 'Chinese_simplified' || 'Croatian' || 'Czech' || 'Danish' || 'Dutch' || 'Estonian' || 'Filipino' || 'Finnish' || 'French' || 'Galician' || 'Hebrew' || 'Hindi' || 'Hungarian' || 'Icelandic' || 'Indonesian' || 'Irish' || 'Italian' || 'Japanese' || 'Korean' || 'Latin' || 'Latvian' || 'Lituanian' || 'Macedonian' || 'Malay' || 'Maltese' || 'Norwegian' || 'Persian' || 'Polish' || 'Poruguese' || 'Romanian' || 'Russian' || 'Serbian' || 'Slovak' || 'Slovenian' || 'Swahili' || 'Swedish' || 'Turkish' || 'Ukranian' || 'Vietnamese' || 'Welsh' || 'Yiddish'
      sms = @client.api.account.messages.create(
        from: "+1#{twilio_phone_number}",
        to: from_number,
        body: EasyTranslate.translate("Awesome, I speak #{message_body} too! It is really nice to meet you!", to: "#{message_body.downcase}", key: 'AIzaSyBukYm7kIRpauOVu6eH7oA-plDDWlEuQBg')
      )

    else
      sms = @client.api.account.messages.create(
        from: "+1#{twilio_phone_number}",
        to: from_number,
        body: "Welcome to Chatbot!! Your number is #{from_number}.  Here are a list of lanaguages I'm fluent in:#{languages}.  What language do you prefer to text in?"
      )
    end
    
  end
 
  private
 
  def boot_twilio
    twilio_sid = ENV['TWILIO_ACCOUNT_SID']
    twilio_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new twilio_sid, twilio_token
  end
end