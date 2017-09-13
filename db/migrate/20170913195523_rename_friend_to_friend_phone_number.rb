class RenameFriendToFriendPhoneNumber < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :friend_id, :friend_phone_number
  end
end
