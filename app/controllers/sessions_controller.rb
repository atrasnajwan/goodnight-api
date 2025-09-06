class SessionsController < ApplicationController
    def login
        user = User.find_by(id: params[:user_id]) # only pass the user_id to login, change for password matching if you want to

        if user.present?
            token = generate_token(user)

            render json: {
                token: token,
                user: {
                    id: user.id,
                    name: user.name
                }
            }, status: :ok
        else

        render json: { error: "User not found" }, status: :unauthorized
        end
    end

    private

    def login_params
        params.permit(:user_id)
    end

    def generate_token(user)
      payload = {
        user_id: user.id,
        exp: 24.hours.from_now.to_i # token expiration time
      }

      JWT.encode(payload, JWT_SECRET_KEY)
    end
end
