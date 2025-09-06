require 'rails_helper'

RSpec.describe UsersController, type: :request do
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

    describe "POST /users/follow" do
        let(:target_user) { create(:user) }
        let(:valid_body) do
            {
                user_id: target_user.id
            }
        end

        let(:invalid_body) do
            {
                user_id: user.id
            }
        end

        context "when authenticated" do
            it "follows a user" do
                post "/users/follow", params: valid_body, as: :json, headers: headers
                expect(response).to have_http_status(:created)
            end

            it "cannot follow himself" do
                post "/users/follow", params: invalid_body, as: :json, headers: headers
                expect(response).to have_http_status(:unprocessable_content)
            end

            it "cannot follow same user" do
                post "/users/follow", params: valid_body, as: :json, headers: headers
                post "/users/follow", params: valid_body, as: :json, headers: headers
                expect(response).to have_http_status(:unprocessable_content)
            end
        end

        context "when unauthenticated" do
            it "returns unauthorized" do
                post "/users/follow", params: valid_body, as: :json
                expect(response).to have_http_status(:unauthorized)
            end
        end
    end

    describe "DELETE /users/unfollow" do
        let(:target_user) { create(:user) }

        let(:valid_body) do
            {
                user_id: target_user.id
            }
        end

        let(:follow_body) do
            {
                user_id: target_user.id
            }
        end

        before do
            post "/users/follow", params: follow_body, as: :json, headers: headers
        end

        it "unfollows a user" do
            delete "/users/unfollow", params: valid_body, as: :json, headers: headers
            expect(response).to have_http_status(:no_content)
        end

        it "returns error if not followed" do
            delete "/users/unfollow", params: valid_body, as: :json, headers: headers
            delete "/users/unfollow", params: valid_body, as: :json, headers: headers
            expect(response).to have_http_status(:unprocessable_content)
        end
    end
end
