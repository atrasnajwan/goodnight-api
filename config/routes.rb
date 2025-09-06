Rails.application.routes.draw do
  # /login
  post "/login", to: "sessions#login"
  # /users
  resources :users, only: [ :index ]
end
