class User < ApplicationRecord
  validates_presence_of :phone_number

  state_machine :state, :initial => :selecting_language do 
    event :select_language do 
      transition :selecting_language => :selecting_number
      end
    event :select_number do
      transition :selecting_number => :messaging_friend
    end
  end

end
