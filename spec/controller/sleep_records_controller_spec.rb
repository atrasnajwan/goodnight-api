require 'rails_helper'

RSpec.describe SleepRecordsController, type: :request do
  let(:user) { create(:user) } # create from FactoryBot
  let(:token) do # token for test logged user
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, JWT_SECRET_KEY)
  end

  let(:headers) do
    {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json"
    }
  end

describe 'POST /sleep_records/clock_in' do
  context "when unauthorized" do
    it "returns 401" do
      post "/sleep_records/clock_in"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # user is not allowed to clock in again before clocking out
  context 'when the user already has an active sleep record' do
    before do
      # create sleep record that not clocked out yet
      create(:sleep_record, user: user, clocked_in_at: Time.now, clocked_out_at: nil)
    end

    it 'returns an error' do
      post "/sleep_records/clock_in", headers: headers # simulate http call

      expect(response).to have_http_status(:unprocessable_content) # match http status code
      expect(JSON.parse(response.body)).to eq({ # match error message
      'message' => 'Already clocked in',
      'error' => 'You must clock out before clock in again'
    })
    end
  end

  context "when the user doesn't have an active sleep record" do
    it 'creates a new sleep record and returns a success' do
      expect {
        post "/sleep_records/clock_in", headers: headers # simulate http call
      }.to change(SleepRecord, :count).by(1) # check if record is added by one

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to have_key('clocked_in_at') # check if clocked_in_at key is returned on the response
    end
  end
end

describe 'PATCH /sleep_records/clock_out' do
  context "when unauthorized" do
    it "returns 401" do
      patch "/sleep_records/clock_out"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  # user is not allowed to clock out if it's already clocked out
  context 'when the user already clock out the sleep record' do
    before do
      # create sleep record that already clocked out
      create(:sleep_record, user: user, clocked_in_at: Time.now, clocked_out_at: Time.current + 8.hours)
    end

    it 'returns an error' do
      patch "/sleep_records/clock_out", headers: headers # simulate http call

      expect(response).to have_http_status(:unprocessable_content) # match http status code
      expect(JSON.parse(response.body)).to eq({ # match error message
        'message' => "Already clocked out",
        'error' => "Can't clock out sleep that you already clocked out"
      })
    end
  end

  context "when the user have an active sleep record" do
    before do
      create(:sleep_record, user: user, clocked_in_at: Time.now, clocked_out_at: nil)
    end

    it 'update clock out time and returns a success' do
      patch "/sleep_records/clock_out", headers: headers # simulate http call

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('clocked_out_at') # check if clocked_out_at is returned on the response
    end
  end
end

describe 'GET /sleep_records' do
  context "when unauthorized" do
    it "returns 401" do
      get "/sleep_records"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when authorized and user has no sleep records" do
    it "returns an empty array" do
      get "/sleep_records", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({
          "data" => [],
          "meta" => {
          "current_page" => 1,
          "next_page" => nil,
          "prev_page" => nil,
          "total_count" => 0,
          "total_pages" => 1
        }
      })
    end
  end

  context "when authorized and user has sleep records" do
    let!(:sleep_record) { create(:sleep_record, user: user) }

    it "returns the sleep record with pagination meta" do
      get "/sleep_records", headers: headers
      expect(response).to have_http_status(:ok)
      response_data = JSON.parse(response.body)

      expect(response_data['data'].length).to eq(1)
      expect(response_data['data'][0]['id']).to eq(sleep_record.id)
      expect(response_data['meta']).to be_present
    end

    it "sorts by clocked_in_at in ascending order by default" do
      sleep_records = create_list(:sleep_record, 3, user: user)

      get "/sleep_records", headers: headers
      response_data = JSON.parse(response.body)
      sorted_ids = response_data['data'].map { |record| record['id'] }

      expect(sorted_ids).to eq(user.sleep_records.order(clocked_in_at: :asc).pluck(:id))
    end

    it "sorts by clocked_in_at in descending order" do
      sleep_records = create_list(:sleep_record, 3, user: user)

      get "/sleep_records", headers: headers, params: { sort_by: 'clocked_in_at', direction: 'desc' }
      response_data = JSON.parse(response.body)
      sorted_ids = response_data['data'].map { |record| record['id'] }

      expect(sorted_ids).to eq(user.sleep_records.order(clocked_in_at: :desc).pluck(:id))
    end

    it "sorts by duration" do
      sleep_record1 = create(:sleep_record, user: user, duration_hours: 5)
      sleep_record2 = create(:sleep_record, user: user, duration_hours: 3)

      get "/sleep_records", headers: headers, params: { sort_by: 'duration', direction: 'asc' }
      response_data = JSON.parse(response.body)
      sorted_ids = response_data['data'].map { |record| record['id'] }

      expect(sorted_ids).to eq([ sleep_record2.id, sleep_record1.id, sleep_record.id ])
    end

    it "returns an error for invalid sort_by parameter" do
      get "/sleep_records", headers: headers, params: { sort_by: 'invalid_field' }
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to eq({
      "error" => "Only clocked_in_at, clocked_out_at, and duration are allowed",
      "message" => "Invalid sort_by parameter"
    })
    end
  end
end

describe 'GET /sleep_records/followings' do
  context "when unauthorized" do
    it "returns 401" do
      get "/sleep_records/followings"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when authorized and user has no following sleep records" do
    it "returns an empty array" do
      get "/sleep_records/followings", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({
        "data" => [],
        "meta" => {
          "current_page" => 1,
          "next_page" => nil,
          "prev_page" => nil,
          "total_count" => 0,
          "total_pages" => 1
        }
      })
    end
  end

  context "when authorized and user has following sleep records" do
    let(:following_user) { create(:user) }
    let!(:sleep_record) { create(:sleep_record, user: following_user, duration_hours: 1.hours, clocked_out_at: Time.now + 1.hours) }

    before do
      # follow someone
      get "/users/follow", params: { user_id: following_user.id }, as: :json, headers: headers
    end

    it "returns the sleep record with pagination meta" do
      get "/sleep_records/followings", headers: headers
      expect(response).to have_http_status(:ok)
      response_data = JSON.parse(response.body)

      expect(response_data['data'].length).to eq(1)
      expect(response_data['data'][0]['id']).to eq(sleep_record.id)
      expect(response_data['data'][0]['user']['id']).to eq(following_user.id)
      expect(response_data['meta']).to be_present
    end

    it "sorts by duration in ascending order by default" do
      create_list(:sleep_record, 3, user: following_user, duration_hours: 1.hours, clocked_out_at: Time.now + 1.hours)

      get "/sleep_records/followings", headers: headers
      response_data = JSON.parse(response.body)
      sorted_ids = response_data['data'].map { |record| record['id'] }

      expect(sorted_ids).to eq(following_user.sleep_records.order(duration_hours: :asc).pluck(:id))
    end

    it "sorts by clocked_out_at in descending order" do
      hours = 1
      while hours <= 3
        create(:sleep_record, user: following_user, duration_hours: hours.hours, clocked_out_at: Time.now + hours.hours)
        hours += 1
      end

      get "/sleep_records/followings", headers: headers, params: { sort_by: 'clocked_out_at', direction: 'desc' }
      response_data = JSON.parse(response.body)
      sorted_ids = response_data['data'].map { |record| record['id'] }

      expect(sorted_ids).to eq(following_user.sleep_records.order(clocked_out_at: :desc).pluck(:id))
    end

    it "sorts by duration" do
      sleep_record1 = create(:sleep_record, user: following_user, duration_hours: 5.hours, clocked_out_at: Time.now + 5.hours)
      sleep_record2 = create(:sleep_record, user: following_user, duration_hours: 3.hours, clocked_out_at: Time.now + 3.hours)

      get "/sleep_records/followings", headers: headers, params: { sort_by: 'duration', direction: 'desc', per_page: 2 }
      response_data = JSON.parse(response.body)
      sorted_ids = response_data['data'].map { |record| record['id'] }

      expect(sorted_ids).to eq([ sleep_record1.id, sleep_record2.id ])
    end

    it "returns an error for invalid sort_by parameter" do
      get "/sleep_records/followings", headers: headers, params: { sort_by: 'invalid_field' }
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)).to eq({
        "error" => "Only clocked_in_at, clocked_out_at, and duration are allowed",
        "message" => "Invalid sort_by parameter"
      })
    end

    it "filters by date range correctly" do
     from_date = 1.week.ago.beginning_of_day
      to_date = Date.today.end_of_day

      sleep_record_in_range = create(:sleep_record, user: following_user, clocked_out_at: from_date + 2.days)
      sleep_record_out_of_range = create(:sleep_record, user: following_user, clocked_out_at: from_date - 1.day)

      get "/sleep_records/followings", headers: headers, params: { from: from_date.strftime('%Y-%m-%d'), to: to_date.strftime('%Y-%m-%d') }
      response_data = JSON.parse(response.body)
      sleep_record_ids = response_data['data'].map { |record| record['id'] }

      expect(sleep_record_ids).to eq([ sleep_record_in_range.id ])
    end
  end
end
end
