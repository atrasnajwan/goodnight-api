FactoryBot.define do
    factory :sleep_record do
      user
      clocked_in_at { Time.now }
      clocked_out_at { nil }
      duration_hours { nil }
    end
end
