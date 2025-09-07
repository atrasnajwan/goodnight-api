class CalculateSleepDurationJob < ApplicationJob
    queue_as :default

    def perform(record_id)
        sleep_record = SleepRecord.find(record_id)
        return if sleep_record.clocked_in_at.nil? || sleep_record.clocked_out_at.nil?

        sleep_record.duration_hours = ((sleep_record.clocked_out_at - sleep_record.clocked_in_at) / 1.hour).round(2)
        sleep_record.save! # Save the record with the calculated duration
    rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error "SleepRecord not found: #{e.message}"
    end
end
