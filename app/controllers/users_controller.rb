class UsersController < ApplicationController
    def index
        pagination, users = pagy(User, limit: params[:per_page] || 10, page: params[:page] || 1)

        render json: {
            data: users,
            meta: pagination_meta(pagination)
        }
    end
end
