Rails.application.routes.draw do
  # /login
  post "/login", to: "sessions#login"
end
