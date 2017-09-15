class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def reply
    message_body = params["Body"]
    from_number = params["From"]
    languages = EasyTranslate::LANGUAGES.values.join("\n").upcase
    twilio_client
    # Take out the first two characters to search in db bc Twilio adds +1 to params["from"]
    num_without_symbol = from_number.slice!(0..1)
    new_num = from_number
    user = User.find_by_phone_number(new_num)
    
    # If user exsists
    if user != nil
      case message_body
      
      # This filters phone numbers, country indicators, extensions, dashes, periods and parenthases
      when /^(?:(?:\(?(?:00|\+)([1-4]\d\d|[1-9]\d?)\)?)?[\-\.\ \\\/]?)?((?:\(?\d{1,}\)?[\-\.\ \\\/]?){0,})(?:[\-\.\ \\\/]?(?:#|ext\.?|extension|x)[\-\.\ \\\/]?(\d+))?$/i
        send_sms(from_number, "You want to text #{message_body}?")
        # Filters white space and any non digit
        # Ensure that a new record doesn't get created for the same number
        # i.e. 330-957-7848 vs 3309577848 
        friend_phone = "#{message_body}"
        friend_phone_number_no_char = friend_phone.gsub(/[\s\D]/,"")
        user.friend_phone_number = friend_phone_number_no_char
        user.save
        
        # Create person 2 with given phone number if the record doesn't already exist
        if User.where(:phone_number => "#{user.friend_phone_number}").blank?
          person_two = User.create(
            :phone_number => user.friend_phone_number
          )
        end
      
      # Set language
      when "Thai\s", "Spanish\s", "Japanese\s" , "German\s", "Greek\s", "Turkish\s", "English\s", "Afrikaans\s", "Albanian\s", "Arabic\s", "Belarusian\s", "Chinese_simplified\s", "Croatian\s", "Czech\s", "Danish\s", "Dutch\s", "Estonian\s", "Filipino\s", "Finnish\s", "French\s", "Galician\s", "Hebrew\s", "Hindi\s", "Hungarian\s", "Icelandic\s", "Indonesian\s", "Irish\s", "Italian\s", "Japanese\s", "Korean\s", "Latin\s", "Latvian\s", "Lituanian\s", "Macedonian\s", "Malay\s", "Maltese\s", "Norwegian\s", "Persian\s", "Polish\s", "Poruguese\s", "Romanian\s", "Russian\s", "Serbian\s", "Slovak\s", "Slovenian\s", "Swahili\s", "Swedish\s", "Turkish\s", "Ukranian\s", "Vietnamese\s", "Welsh\s", "Yiddish\s"
        send_sms(from_number, "You set your language as #{message_body}.  Please, enter the phone number you would like to message.")
        user = User.find_by_phone_number(new_num)
        user.language = "#{message_body}"
        user.save
      
      when "Yes", "yes"
        send_sms(from_number, "Alright, what would you like to say?")
      
      when "No", "no"
        send_sms(from_number, "Alright, what phone number would you like to message?")
        user.update(friend_phone_number: nil)
      
      else
        # Look for person 2 in the database and check if language is nil =>prompt to set language
        friend = User.find_by_phone_number("#{user.friend_phone_number}")
        if friend.language == nil
          send_sms(friend_phone_number, "Hey there! #{user.phone_number} wants to chat with you. Here are a list of languages I'm fluent in:\n#{languages}.\nWhat language do you prefer to text in?")

        # If person 2 has langauge set => send message
        else
          send_sms(friend.phone_number, EasyTranslate.translate("#{user.phone_number} says:\n#{message_body}", to: "#{friend.language.downcase}", key: ENV['GOOGLE_TRANSLATE_KEY']))
        end
      end
    
    # If user doesn't exist
    else
      user = User.create(
        :phone_number => from_number
      )
      send_sms(from_number, "Welcome to Chatbot!! Here are a list of languages I'm fluent in:\n#{languages}.\nWhat language do you prefer to text in?" )
    end 
  end

  def send_sms(recipient_phone_number, message)
    twilio_phone_number = '2164782291'
    twilio_client.api.account.messages.create(
      to: recipient_phone_number,
      from: "+1#{twilio_phone_number}",
      body: message
    )
  end
 
  
  private
 
  def twilio_client
    twilio_sid = ENV['TWILIO_ACCOUNT_SID']
    twilio_token = ENV['TWILIO_AUTH_TOKEN']
    Twilio::REST::Client.new twilio_sid, twilio_token
  end
end