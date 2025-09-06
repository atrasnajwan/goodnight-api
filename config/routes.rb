Rails.application.routes.draw do
  # /login
  post "/login", to: "sessions#login"

  # /users
  resources :users, only: [ :index ] do
    collection do
      # GET /users/followings
      get "followings"
      # GET /users/followers
      get "followers"
      # POST /users/follow
      post "follow"
      # DEL /users/unfollow
      delete "unfollow"
    end
  end
end
