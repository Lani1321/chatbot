class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def reply
    message_body = params["Body"]
    from_number = params["From"]
    twilio_phone_number = '2164782291'
    
    languages = EasyTranslate::LANGUAGES.values.join("\n").upcase
    # translation = EasyTranslate.translate("#{message_body}", :to => :th, :key => ENV[google_auth])
    # languages = 
    #   EasyTranslate::LANGUAGES.values.each.with_index do |lang, i|
    #     puts "#{i+1}. #{lang}"
    #   end
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    # Take out the first two characters to search in db bc Twilio adds +1 to params["from"]
    num_without_symbol = from_number.slice!(0..1)
    new_num = from_number
    user = User.find_by_phone_number(new_num)
    # If user exsists
    if user != nil
      case message_body
      # This accounts for phone numbers, country indicators, extensions, dashes, periods and parenthases
      when /^(?:(?:\(?(?:00|\+)([1-4]\d\d|[1-9]\d?)\)?)?[\-\.\ \\\/]?)?((?:\(?\d{1,}\)?[\-\.\ \\\/]?){0,})(?:[\-\.\ \\\/]?(?:#|ext\.?|extension|x)[\-\.\ \\\/]?(\d+))?$/i
        @client.api.account.messages.create(
          from: "+1#{twilio_phone_number}",
          to: from_number,
          body: "You want to text #{message_body}?"
        )
        user.friend_phone_number = "#{message_body}"
        user.save
        # Create person 2 with given phone number if the record doesn't already exist
        if User.where(:phone_number => "#{user.friend_phone_number}").blank?
          person_two = User.create(
            :phone_number => user.friend_phone_number
          )
        end
      # Set language
      when "Thai", "Spanish", "Japanese" , "German", "Greek", "Turkish", "English", "Afrikaans", "Albanian", "Arabic", "Belarusian", "Chinese_simplified", "Croatian", "Czech", "Danish", "Dutch", "Estonian", "Filipino", "Finnish", "French", "Galician", "Hebrew", "Hindi", "Hungarian", "Icelandic", "Indonesian", "Irish", "Italian", "Japanese", "Korean", "Latin", "Latvian", "Lituanian", "Macedonian", "Malay", "Maltese", "Norwegian", "Persian", "Polish", "Poruguese", "Romanian", "Russian", "Serbian", "Slovak", "Slovenian", "Swahili", "Swedish", "Turkish", "Ukranian", "Vietnamese", "Welsh", "Yiddish"
        @client.api.account.messages.create(
          from: "+1#{twilio_phone_number}",
          to: from_number,
          body: "You set your language as #{message_body}.  Please, enter the phone number you would like to message."
        )
        user = User.find_by_phone_number(new_num)
        user.language = "#{message_body}"
        user.save
      when "Yes", "yes"
        @client.api.account.messages.create(
          from: "+1#{twilio_phone_number}",
          to: from_number,
          body: "Alright, what would you like to say?"
        )
      when "No", "no"
        @client.api.account.messages.create(
          from: "+1#{twilio_phone_number}",
          to: from_number,
          body: "Alright, what phone number would you like to message?"
        )
        user.update(friend_phone_number: nil)
      else
        # Look for person 2 in the database and check if language is nil =>prompt to set language
        friend = User.find_by_phone_number("#{user.friend_phone_number}")
        if friend.language == nil
          @client.api.account.messages.create(
            from: "+1#{twilio_phone_number}",
            to: friend.phone_number, 
            body: "Hey there! #{user.phone_number} wants to chat with you. Here are a list of languages I'm fluent in:\n#{languages}.\nWhat language do you prefer to text in?"
          )
        # If person 2 has langauge set => send message
        else
          @client.api.account.messages.create(
            from: "+1#{twilio_phone_number}",
            to: friend.phone_number,
            body: EasyTranslate.translate("#{user.phone_number} says:\n#{message_body}", to: "#{friend.language.downcase}", key: ENV['google_auth'])
            # EasyTranslate.translate("#{user.phone_number} says:\n'#{message_body}", to: "#{friend.language.downcase}", key: 'AIzaSyBukYm7kIRpauOVu6eH7oA-plDDWlEuQBg')
            )
        end
      end
    # If user doesn't exist
    else
      user = User.create(
        :phone_number => from_number
      )
      @client.api.account.messages.create(
        from: "+1#{twilio_phone_number}",
        to: from_number,
        body: "Welcome to Chatbot!! Here are a list of languages I'm fluent in:\n#{languages}.\nWhat language do you prefer to text in?"
      )
      # end
    end 
  end
  # Create person 2 an account when user provides a friend phone number
  # have SMS take arguments, who you're sending it to, and what the message is)
  def send_sms(recipient_phone_number, message)
    to = params["To"] #=> comment this line out if it takes arguments
    sms = params["Body"] #=>coment this line out if it takes arguments
    twilio_sid = ENV['TWILIO_ACCOUNT_SID'], 
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