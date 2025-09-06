class UsersController < ApplicationController
    before_action :authenticate_user, only: [ :followers, :followings, :follow, :unfollow ] # required to login

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

    def follow
        user_id = params[:user_id].to_i

        if user_id == current_user.id
            return render json: {
                    message: "Can not follow",
                    error: "You can not follow yourself"
                }, status: :unprocessable_entity
        end

        user_to_follow = User.find_by(id: user_id)

        if user_to_follow.present?
            is_already_follow = current_user.followings.find_by(id: user_to_follow.id)

            if is_already_follow
                return render json: {
                        message: "Already follow",
                        error: "You already follow this User"
                    }, status: :unprocessable_entity
            end

            ::Following.create!(
                follower_id: current_user.id,
                followed_id: user_to_follow.id
            )

            render json: { message: "Now following #{user_to_follow.name}" }, status: :created
        else
            render json: { error: "User not found" }, status: :not_found # not_found == http status code 404
        end
    end

    def unfollow
    end
end
