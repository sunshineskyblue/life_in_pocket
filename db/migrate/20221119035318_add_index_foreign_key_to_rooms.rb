class AddIndexForeignKeyToRooms < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :rooms, :users
    add_index :rooms, :user_id
  end
end
