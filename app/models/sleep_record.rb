class SleepRecord < ApplicationRecord
    include PgParty::Model

    self.primary_key = :id
    belongs_to :user
    before_create :set_clocked_in_at

    # callback before saving to db if clocked_out_at column changed
    before_save :calculate_sleep_duration, if: :clocked_out_at_changed?

    # daily partition
    range_partition_by :clocked_in_at

    private
    # set clocked_in_at to current time
    def set_clocked_in_at
        self.clocked_in_at ||= Time.current
    end

    def calculate_sleep_duration
        return if clocked_in_at.nil? || clocked_out_at.nil?

        self.duration_hours = ((self.clocked_out_at - self.clocked_in_at) / 1.hour).round(2)
    end
end
