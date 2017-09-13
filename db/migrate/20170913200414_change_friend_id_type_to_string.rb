class ChangeFriendIdTypeToString < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :friend_phone_number, :string
  end
end
