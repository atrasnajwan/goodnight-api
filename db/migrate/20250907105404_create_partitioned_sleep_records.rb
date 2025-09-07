class CreatePartitionedSleepRecords < ActiveRecord::Migration[8.0]
  def up
    drop_table :sleep_records, if_exists: true

    # Create partition parent table
    create_range_partition :sleep_records, partition_key: :clocked_in_at do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :clocked_in_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :clocked_out_at
      t.decimal  :duration_hours, precision: 10, scale: 2

      t.timestamps
    end
  end

  def down
    drop_table :sleep_records
  end
end
