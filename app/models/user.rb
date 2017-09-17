class User < ApplicationRecord
  validates_presence_of :phone_number

  state_machine :state, :initial => :selecting_language do 
    event :select_language do 
      transition :selecting_language => :selecting_number
    end
  end

  # This *must* be called, otherwise states won't get initialized
  def initialize
    super()
  end

end
