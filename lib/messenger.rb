class Messenger

  def self.respond_to_text(message_body, from_number)
    user = User.find_by_phone_number(from_number)
    languages = EasyTranslate::LANGUAGES.values.join("\n").upcase
    # If user exists
    if user != nil
      # This filters phone numbers, country indicators, extensions, dashes, periods and parenthases
      # when /^(?:(?:\(?(?:00|\+)([1-4]\d\d|[1-9]\d?)\)?)?[\-\.\ \\\/]?)?((?:\(?\d{1,}\)?[\-\.\ \\\/]?){0,})(?:[\-\.\ \\\/]?(?:#|ext\.?|extension|x)[\-\.\ \\\/]?(\d+))?$/i
      
      if user.state == "selecting_number"  
        send_sms(from_number, "You will be sending messages to: #{message_body}")
        
        # Filters white space and any non digit
        # Ensure that a new record doesn't get created for the same number
        # i.e. 330-957-7848 vs 3309577848 
        friend_phone = message_body
        friend_phone_number_no_char = friend_phone.gsub(/[\s\D]/,"")
        user.update(friend_phone_number: friend_phone_number_no_char)
        user.select_number
        
        # Create person 2 with given phone number if the record doesn't already exist
        if User.where(:phone_number => "#{user.friend_phone_number}").blank?
          User.create(
            :phone_number => user.friend_phone_number
          )
        end
      
      # Set language
      # when "Thai", "Spanish", "Japanese", "German", "Greek", "Turkish", "English", "Afrikaans", "Albanian", "Arabic", "Belarusian", "Chinese_simplified", "Croatian", "Czech", "Danish", "Dutch", "Estonian", "Filipino", "Finnish", "French", "Galician", "Hebrew", "Hindi", "Hungarian", "Icelandic", "Indonesian", "Irish", "Italian", "Japanese", "Korean", "Latin", "Latvian", "Lituanian", "Macedonian", "Malay", "Maltese", "Norwegian", "Persian", "Polish", "Poruguese", "Romanian", "Russian", "Serbian", "Slovak", "Slovenian", "Swahili", "Swedish", "Turkish", "Ukranian", "Vietnamese", "Welsh", "Yiddish"
      elsif user.state == "selecting_language"
        send_sms(from_number, "You set your language as #{message_body}.  Please, enter the phone number you would like to message.")
        user = User.find_by_phone_number(from_number)
        user.update(language: message_body)
        user.select_language

      # User state will be messaging_friend
      else
        # Look for person 2 in the database and check if language is nil =>prompt to set language
        friend = User.find_by_phone_number("#{user.friend_phone_number}")
        if friend.language == nil
          send_sms(friend.phone_number, "Hey there! #{user.phone_number} wants to chat with you. Here are a list of languages I'm fluent in:\n#{languages}.\nWhat language do you prefer to text in?")

        # If person 2 has langauge set => send message
        else
          send_sms(friend.phone_number, EasyTranslate.translate("#{user.phone_number} says:\n#{message_body}", to: "#{friend.language.downcase}", key: Rails.application.secrets[:google_translate_key]))
        end
      end
    
    # If user doesn't exist
    # User state is selecting language
    else
      user = User.create(
        :phone_number => from_number
      )
      send_sms(from_number, "Welcome to Chatbot!! Here are a list of languages I'm fluent in:\n#{languages}.\nWhat language do you prefer to text in?" )
    end 
  end

  def self.send_sms(recipient_phone_number, message)
    twilio_phone_number = '2164782291'
    twilio_client.api.account.messages.create(
      to: recipient_phone_number,
      from: "+1#{twilio_phone_number}",
      body: message
    )
  end

  def self.twilio_client
    twilio_sid = Rails.application.secrets[:twilio_account_sid]
    twilio_token = Rails.application.secrets[:twilio_auth_token]
    Twilio::REST::Client.new twilio_sid, twilio_token
  end

end
