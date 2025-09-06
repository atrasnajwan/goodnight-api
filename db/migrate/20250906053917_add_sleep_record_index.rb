class AddSleepRecordIndex < ActiveRecord::Migration[8.0]
  def change
    add_index :sleep_records, :clocked_in_at # for sort by clocked_in
  end
end
