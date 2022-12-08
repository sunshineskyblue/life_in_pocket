class CreateReservations < ActiveRecord::Migration[6.1]
  def change
    create_table :reservations do |t|
      t.date       :checkin,         null:false
      t.date       :checkout,        null:false
      t.integer    :number,          null:false
      t.integer    :payment,         null:false
      t.boolean    :cancel,          null:false,   default: false
      t.boolean    :cancel_request,  null:false,   default: false
      t.references :guest,           null: false,  foreign_key: { to_table: :users }
      t.references :host,            null: false,  foreign_key: { to_table: :users }

      t.timestamps
    end

    add_reference :reservations, :room, foreign_key: true, null: false, index: false

    # 予約バリデーションでの高速化を想定
    add_index :reservations, [:room_id, :checkin, :checkout], name: :start_room_id
  end
end
