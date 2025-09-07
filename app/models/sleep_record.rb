class SleepRecord < ApplicationRecord
    belongs_to :user
    before_create :set_clocked_in_at

    # callback before saving to db if clocked_out_at column changed
    before_save :calculate_sleep_duration, if: :clocked_out_at_changed?

    private
    # set clocked_in_at to current time
    def set_clocked_in_at
        self.clocked_in_at ||= Time.current
    end

    def calculate_sleep_duration
        return if clocked_in_at.nil? || clocked_out_at.nil?

        # Calculate duration in a background job
        CalculateSleepDurationJob.perform_later(self.id)
    end
end
