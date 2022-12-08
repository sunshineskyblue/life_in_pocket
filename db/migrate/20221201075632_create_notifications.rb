class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :guest,       null: false,  foreign_key: { to_table: :users }
      t.references :host,        null: false,  foreign_key: { to_table: :users }
      t.references :reservation, null: false
      t.string     :action,      null: false, default: ''
      t.boolean    :checked,     null: false, default: false

      t.timestamps
    end
  end
end
