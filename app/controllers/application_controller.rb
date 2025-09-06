class ApplicationController < ActionController::API
    include Pagy::Backend

    attr_reader :current_user

    # handle if got wrong page/out of scope page
    rescue_from Pagy::OverflowError do
      render json: { error: "Page out of range" }, status: :bad_request
    end

    private

    def pagination_meta(pagy)
        {
            current_page: pagy.page,
            next_page: pagy.next,
            prev_page: pagy.prev,
            total_pages: pagy.pages,
            total_count: pagy.count
        }
    end

    def authenticate_user
      header = request.headers["Authorization"]
      return render json: { error: "Missing token" }, status: :unauthorized unless header # check HTTP header

      token = header.split(" ").last

      begin
        decoded = JWT.decode(token, JWT_SECRET_KEY)[0] # decode JWT token
        @current_user = User.find(decoded["user_id"])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: "Invalid or expired token" }, status: :unauthorized
      end
    end
end
