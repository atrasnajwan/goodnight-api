class SleepRecordSerializer < ActiveModel::Serializer
    attributes :id, :clocked_in_at, :clocked_out_at, :duration

    def duration
        return if object.duration_hours.nil?

        return "#{object.duration_hours} hours" if object.duration_hours >= 1.00

        "#{object.duration_hours * 60} minutes"
    end
end
