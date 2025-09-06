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

  # /sleep_records
  resources :sleep_records, only: [ :index ]

  namespace :sleep_records do
    # /sleep_records/clock_in
    post "clock_in"
    # /sleep_records/clock_out
    patch "clock_out"
  end
end
