class AddDurationOnSleepRecords < ActiveRecord::Migration[8.0]
  def change
    # add as column because it will only changes once
    add_column :sleep_records, :duration_hours, :decimal, precision: 10, scale: 2
    # add index on duration_hours if clocked_out_at is not null
    add_index :sleep_records, :duration_hours, where: "clocked_out_at IS NOT NULL"
    add_index :sleep_records, [ :user_id, :duration_hours ], where: "clocked_out_at IS NOT NULL"
  end
end
