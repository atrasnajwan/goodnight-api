# app/jobs/create_sleep_record_partition_job.rb
class CreateSleepRecordPartitionJob < ApplicationJob
  queue_as :default

  def perform
    tomorrow = Date.tomorrow
    table_name = "sleep_records_#{tomorrow.strftime('%Y_%m_%d')}"

    unless ActiveRecord::Base.connection.data_source_exists?(table_name)
        SleepRecord.create_partition(start_range: tomorrow, end_range: tomorrow + 1.day)

        # Add indexes to partition table
        ActiveRecord::Base.connection.execute("CREATE INDEX IF NOT EXISTS sleep_records_#{tomorrow.strftime('%Y_%m_%d')}_user_id_clocked_in_at_idx ON sleep_records_#{tomorrow.strftime('%Y_%m_%d')} USING btree(user_id, clocked_in_at);")
        ActiveRecord::Base.connection.execute("CREATE INDEX IF NOT EXISTS sleep_records_#{tomorrow.strftime('%Y_%m_%d')}_user_id_clocked_out_at_idx ON sleep_records_#{tomorrow.strftime('%Y_%m_%d')} USING btree(user_id, clocked_out_at);")
        ActiveRecord::Base.connection.execute("CREATE INDEX IF NOT EXISTS sleep_records_#{tomorrow.strftime('%Y_%m_%d')}_user_id_duration_hours_idx ON sleep_records_#{tomorrow.strftime('%Y_%m_%d')} USING btree(user_id, duration_hours) WHERE clocked_out_at IS NOT NULL;")
    end

    Rails.logger.info "[Partition] ensured #{table_name}"
  rescue => e
    Rails.logger.error "[Partition] failed to create partition: #{e.class}: #{e.message}"
    raise
  end
end
