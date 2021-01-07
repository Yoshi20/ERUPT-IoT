Rails.application.routes.draw do

  get 'home' => 'home#index'

  devise_for :users
  resources :users, only: [:index, :update, :destroy]

  root to: "home#index"

end
