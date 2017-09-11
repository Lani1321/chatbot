class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.integer :id
      t.string :language
      t.string :phone
      t.integer :friend_id

      t.timestamps
    end
  end
end
