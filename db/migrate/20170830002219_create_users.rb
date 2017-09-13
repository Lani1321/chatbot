class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :language
      t.string :phone
      t.integer :friend_id #==> another user_id
    end
  end
end

# Person 1 
# Person 2 ==> friend_id uniq
# Person 3 ==> user_id
# Or you can go off of the phone number

# Problem: user 1 wont be able to find user 2
# Solution: use friend_id ==> Should this be a uniq character or should it be another word for user_id
# Every user has a uniq id
# friend_id is person's phone number*

# User where :phone = self.friend_id

# User 1
# language: English
# Who do you want to talk to?
# friend_id: friends phone number


# Forward message to friend 2
# if not a current user then do a setup
# Search database if phone number exsists

# Text from any user with no number in the database
# What language do you speak?
# Who do you want to chat with?