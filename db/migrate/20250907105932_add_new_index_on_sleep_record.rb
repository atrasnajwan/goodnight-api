class AddNewIndexOnSleepRecord < ActiveRecord::Migration[8.0]
  def change
    add_index :sleep_records, [ :user_id, :clocked_in_at ]
    add_index :sleep_records, [ :user_id, :clocked_out_at ]

    add_index :sleep_records, [ :user_id, :duration_hours ], where: "clocked_out_at IS NOT NULL"
  end
end
