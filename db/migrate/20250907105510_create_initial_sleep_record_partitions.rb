class CreateInitialSleepRecordPartitions < ActiveRecord::Migration[8.0]
  def change
    today = Date.today
    tomorrow = Date.tomorrow

    create_range_partition_of :sleep_records,
                              name: "sleep_records_#{today.strftime('%Y_%m_%d')}",
                              start_range: today,
                              end_range: tomorrow
    add_index "sleep_records_#{today.strftime('%Y_%m_%d')}", [ :user_id, :clocked_in_at ]
    add_index "sleep_records_#{today.strftime('%Y_%m_%d')}", [ :user_id, :clocked_out_at ]
    add_index "sleep_records_#{today.strftime('%Y_%m_%d')}", [ :user_id, :duration_hours ], where: "clocked_out_at IS NOT NULL"

    create_range_partition_of :sleep_records,
                              name: "sleep_records_#{tomorrow.strftime('%Y_%m_%d')}",
                              start_range: tomorrow,
                              end_range: tomorrow + 1.day
    add_index "sleep_records_#{tomorrow.strftime('%Y_%m_%d')}", [ :user_id, :clocked_in_at ]
    add_index "sleep_records_#{tomorrow.strftime('%Y_%m_%d')}", [ :user_id, :clocked_out_at ]
    add_index "sleep_records_#{tomorrow.strftime('%Y_%m_%d')}", [ :user_id, :duration_hours ], where: "clocked_out_at IS NOT NULL"
  end
end
