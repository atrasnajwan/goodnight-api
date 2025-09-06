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
end
