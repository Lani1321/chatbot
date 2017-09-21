class User < ApplicationRecord
  validates_presence_of :phone_number

  state_machine :state, :initial => :selecting_language do 
    event :select_language do 
      transition :selecting_language => :selecting_number
    end
    event :select_number do
      transition :selecting_number => :messaging_friend
    end
    event :select_language_person_two do 
      transition :selecting_language => :messaging_friend
    end

    # Onset changing language
    event :change_language do
      transition :messaging_friend => :changed_language
    end

    # Update new language and go back to messaging
    event :set_new_language do
      transition :changed_language => :messaging_friend
    end
  end

end
