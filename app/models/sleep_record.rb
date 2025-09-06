class SleepRecord < ApplicationRecord
    belongs_to :user
    before_create :set_clocked_in_at

    private
    # set clocked_in_at to current time
    def set_clocked_in_at
        self.clocked_in_at ||= Time.current
    end
end
