Rails.application.routes.draw do
  get 'home' => 'home#index'

  resources :devices
  resources :members

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions', passwords: 'users/passwords' }
  resources :users, only: [:index, :update, :destroy]

  root to: "home#index"

end
