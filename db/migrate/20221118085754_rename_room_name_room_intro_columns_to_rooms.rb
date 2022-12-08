class RenameRoomNameRoomIntroColumnsToRooms < ActiveRecord::Migration[6.1]
  def change
    rename_column :rooms, :room_name,  :name
    rename_column :rooms, :room_intro, :introduction
  end
end
