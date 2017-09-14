class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def reply
    message_body = params["Body"]
    from_number = params["From"]
    twilio_phone_number = '2164782291'
    twilio_sid = ENV['TWILIO_ACCOUNT_SID']
    twilio_token = ENV['TWILIO_AUTH_TOKEN']
    languages = EasyTranslate::LANGUAGES.values.join("\n").upcase
    # translation = EasyTranslate.translate("#{message_body}", :to => :th, :key => ENV['google_auth_key'])
    # languages = 
    #   EasyTranslate::LANGUAGES.values.each.with_index do |lang, i|
    #     puts "#{i+1}. #{lang}"
    #   end
    # user = User.find_by_phone_number(from_number)
    # if user != nil
    @client = Twilio::REST::Client.new twilio_sid, twilio_token
    num_without_symbol = from_number.slice!(0..1)
    new_num = from_number
    user = User.find_by_phone_number(new_num)
    if user != nil
      case message_body
      when /^(?:(?:\(?(?:00|\+)([1-4]\d\d|[1-9]\d?)\)?)?[\-\.\ \\\/]?)?((?:\(?\d{1,}\)?[\-\.\ \\\/]?){0,})(?:[\-\.\ \\\/]?(?:#|ext\.?|extension|x)[\-\.\ \\\/]?(\d+))?$/i
        sms = @client.api.account.messages.create(
          from: "+1#{twilio_phone_number}",
          to: from_number,
          body: "You want to text #{message_body}?"
        )
        user.friend_phone_number = "#{message_body}"
        user.save
      when "Thai", "Spanish", "Japanese" , "German", "Greek", "Turkish", "English", "Afrikaans", "Albanian", "Arabic", "Belarusian", "Chinese_simplified", "Croatian", "Czech", "Danish", "Dutch", "Estonian", "Filipino", "Finnish", "French", "Galician", "Hebrew", "Hindi", "Hungarian", "Icelandic", "Indonesian", "Irish", "Italian", "Japanese", "Korean", "Latin", "Latvian", "Lituanian", "Macedonian", "Malay", "Maltese", "Norwegian", "Persian", "Polish", "Poruguese", "Romanian", "Russian", "Serbian", "Slovak", "Slovenian", "Swahili", "Swedish", "Turkish", "Ukranian", "Vietnamese", "Welsh", "Yiddish"
        sms = @client.api.account.messages.create(
          from: "+1#{twilio_phone_number}",
          to: from_number,
          body: "You set your language as #{message_body}.  Please, enter the phone number you would like to message."
        )
        user.language = "#{message_body}"
        user.save
      when "Yes", "yes"
        sms = @client.api.account.messages.create(
          from: "+1#{twilio_phone_number}",
          to: from_number,
          body: "Alright, what would you like to say?"
        )
        self.send_sms
      when "No", "no"
        sms = @client.api.account.messages.create(
          from: "+1#{twilio_phone_number}",
          to: from_number,
          body: "Alright, what phone number would you like to message?"
        )
        user.update(friend_phone_number: nil)
      else
        sms = @client.api.account.messages.create(
          from: "+1#{twilio_phone_number}",
          to: from_number,
          body: "Welcome back! Please enter the phone number you would like to message"
        )
      end

    else
      case message_body 
      when "Thai", "Spanish", "Japanese" , "German", "Greek", "Turkish", "English", "Afrikaans", "Albanian", "Arabic", "Belarusian", "Chinese_simplified", "Croatian", "Czech", "Danish", "Dutch", "Estonian", "Filipino", "Finnish", "French", "Galician", "Hebrew", "Hindi", "Hungarian", "Icelandic", "Indonesian", "Irish", "Italian", "Japanese", "Korean", "Latin", "Latvian", "Lituanian", "Macedonian", "Malay", "Maltese", "Norwegian", "Persian", "Polish", "Poruguese", "Romanian", "Russian", "Serbian", "Slovak", "Slovenian", "Swahili", "Swedish", "Turkish", "Ukranian", "Vietnamese", "Welsh", "Yiddish"
        sms = @client.api.account.messages.create(
          from: "+1#{twilio_phone_number}",
          to: from_number,
          body: "You set your language as #{message_body}.  Please, enter the phone number you would like to message."
        )

      else
        user = User.create(
          :phone_number => from_number
        )
        sms = @client.api.account.messages.create(
          from: "+1#{twilio_phone_number}",
          to: from_number,
          body: "Welcome to Chatbot!! Here are a list of lanaguages I'm fluent in:\n#{languages}.\nWhat language do you prefer to text in?"
        )
      end
    end 
  end

  def send_sms
    to = params["To"]
    sms = params["Body"]
    twilio_sid = ENV['TWILIO_ACCOUNT_SID']
    twilio_token = ENV['TWILIO_AUTH_TOKEN']
    twilio_phone_number = '2164782291'
    user = User.new 
    @client = Twilio::REST::Client.new twilio_sid, twilio_token 
    @client.api.account.messages.create(
      to: to,
      from: "+1#{twilio_phone_number}",
      body: sms
    )
  end
 
  private
 
  def boot_twilio
    twilio_sid = ENV['TWILIO_ACCOUNT_SID']
    twilio_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new twilio_sid, twilio_token
  end
end