Rails.application.routes.draw do
  get 'home' => 'home#index'

  get 'members/extern', to: redirect('members/extern/new')
  get 'members/extern/new' => 'members#new_extern'
  post 'members/extern' => 'members#create_extern'
  get 'members/extern/success' => 'members#success_extern'
  resources :devices
  resources :members
  resources :scan_events, only: [:index, :create, :destroy]

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions', passwords: 'users/passwords' }
  resources :users, only: [:index, :update, :destroy]

  devise_scope :user do
    root to: "devise/sessions#new"
  end

end
