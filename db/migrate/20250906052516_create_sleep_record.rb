class CreateSleepRecord < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.datetime :clocked_in_at, default: -> { 'CURRENT_TIMESTAMP' }, null: false # need to clocked in to sleep
      t.datetime :clocked_out_at

      t.timestamps
    end
  end
end


