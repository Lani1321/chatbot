class Messenger

  def self.respond_to_text(message_body, from_number)
    user = User.find_by_phone_number(from_number)
    
    languages = EasyTranslate::LANGUAGES.values.join("\n").upcase
    
    # If user exists
    if user != nil    
      if user.state == "selecting_number"  
        save_friend_num(message_body, from_number)
      
      # Set language
      elsif user.state == "selecting_language"
        set_language(message_body, from_number)
  
      elsif user.state == "person_two_select_language"
      # User state is messaging_friend
      else
        chat_bot(message_body, from_number)
      end
    
    # If user doesn't exist
    # User state is selecting language
    else
      set_language_for_user_one(message_body, languages, from_number)
    end
  end

  def self.save_friend_num(message_body, from_number)
    
    # This filters phone numbers, country indicators, dashes, periods and parenthases
    if message_body =~ /[0-9, +, ., -, (, ), -]{10,15}/
      user = User.find_by_phone_number(from_number)
      send_sms(from_number, "You will be sending messages to: #{message_body}")
          
      # Filters white space and any non digit
      # Ensure that a new record doesn't get created for the same number
      # i.e. 330-957-7848 vs 3309577848 
      friend_phone = message_body
      friend_phone_number_no_char = friend_phone.gsub(/[\s\D]/,"")
      user.update(friend_phone_number: friend_phone_number_no_char)
      user.select_number
      if User.where(:phone_number => "#{user.friend_phone_number}").blank?
        User.create(
          :phone_number => user.friend_phone_number,
          :friend_phone_number => user.phone_number
        )
      end
    else
      send_sms(from_number, "Please enter a valid phone number")
    end
  end

  def self.set_language(message_body, from_number)
    downcase_input = message_body.downcase
    if downcase_input.in?(EasyTranslate::LANGUAGES.values)
      user = User.find_by_phone_number(from_number)

      # We don't want user inputting a phone number when they are person two
      if user.phone_number && user.friend_phone_number
        send_sms(from_number, "You set your language to #{message_body}.  You can start messaging now!")
        user.update(language: message_body)
        user.select_language_person_two
      else 
        send_sms(from_number, "You set your language to #{message_body}.  Please, enter the phone number you would like to message.")
        user.update(language: message_body)
        user.select_language
      end
    else
      send_sms(from_number, "I'm sorry, I don't recognize that language.  Please, take a look at the list of available languages and try again.")
    end
  end

  def self.chat_bot(message_body, from_number)
    user = User.find_by_phone_number(from_number)
    friend = User.find_by_phone_number("#{user.friend_phone_number}")
    
    # Look for person 2 in the database and check if language is nil =>prompt to set language
    if friend.language == nil
      set_language_for_friend(friend, user, message_body)
    
    # If person 2 has langauge set => send message
    else
      send_translated_message(friend, user, message_body)
    end
  end

  def self.set_language_for_friend(friend, user, message_body)
    languages = EasyTranslate::LANGUAGES.values.join("\n").upcase
    send_sms(friend.phone_number, "Hey there! #{user.phone_number} wants to chat with you. Here are a list of languages I'm fluent in:\n#{languages}.\nWhat language do you prefer to text in?")
  end

  def self.send_translated_message(friend, user, message_body)
    send_sms(friend.phone_number, EasyTranslate.translate("#{user.phone_number} says:\n#{message_body}", to: "#{friend.language.downcase}", key: Rails.application.secrets[:google_translate_key]))
  end

  def self.set_language_for_user_one(message_body, languages, from_number)
    user = User.create(
      :phone_number => from_number
      )
    send_sms(from_number, "Welcome to Chatbot!! Here are a list of languages I'm fluent in:\n#{languages}.\nWhat language do you prefer to text in?" )
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
