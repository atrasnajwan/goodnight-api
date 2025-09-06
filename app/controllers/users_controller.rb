class UsersController < ApplicationController
    before_action :authenticate_user, only: [ :followers, :followings ] # required to login

    def index
        pagination, users = pagy(User, limit: params[:per_page] || 10, page: params[:page] || 1)

        render json: {
            data: users,
            meta: pagination_meta(pagination)
        }
    end

    def followers
        pagination, users = pagy(
                                current_user.followers.order(created_at: :desc), # sort by latest
                                limit: params[:per_page] || 10,
                                page: params[:page] || 1
                            )

        render json: {
            data: users,
            meta: pagination_meta(pagination)
        }
    end

    def followings
        pagination, users = pagy(
                                current_user.followings.order(created_at: :desc), # sort by latest
                                limit: params[:per_page] || 10,
                                page: params[:page] || 1
                            )

        render json: {
            data: users,
            meta: pagination_meta(pagination)
        }
    end
end
