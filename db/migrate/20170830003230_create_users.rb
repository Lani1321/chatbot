class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :users
      t.integer :id
      t.string :language
    end
  end
end
