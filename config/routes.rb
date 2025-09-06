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
    end
  end
end
