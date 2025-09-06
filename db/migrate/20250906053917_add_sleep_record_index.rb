class AddSleepRecordIndex < ActiveRecord::Migration[8.0]
  def change
    add_index :sleep_records, :clocked_in_at # for sort by clocked_in_at
    add_index :sleep_records, :clocked_out_at # for sort by clocked_out_at
    add_index :sleep_records, [ :user_id, :clocked_in_at ]
    add_index :sleep_records, [ :user_id, :clocked_out_at ]
  end
end
