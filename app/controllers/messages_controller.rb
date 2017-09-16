class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def reply
    message_body = params["Body"]
    from_number = params["From"][2..-1]
    Messenger.respond_to_text(message_body, from_number)
  end 

end