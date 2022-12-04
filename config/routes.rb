Rails.application.routes.draw do

  mount ActionCable.server => '/cable'

  get 'games' => 'games#index'
  get 'games_for_iframe' => 'games#index_for_iframe'
  get 'games_refresh' => 'games#refresh'

  post 'lora_uplink' => 'uplinks#lora_uplink'

  get 'membership' => 'membership#index'

  resources :devices
  get 'members/extern', to: redirect('members/extern/new')
  get 'members/extern/new' => 'members#new_extern'
  post 'members/extern' => 'members#create_extern'
  get 'members/extern/success' => 'members#success_extern'
  post 'members/sync_with_ggleap' => 'members#sync_with_ggleap'
  resources :members
  resources :scan_events, only: [:index, :show, :edit, :create, :update, :destroy]
  get 'feedbacks/extern', to: redirect('feedbacks/extern/new')
  get 'feedbacks/extern/new' => 'feedbacks#new_extern'
  post 'feedbacks/extern' => 'feedbacks#create_extern'
  get 'feedbacks/extern/success' => 'feedbacks#success_extern'
  resources :feedbacks
  resources :orders, only: [:index, :show, :update, :destroy]
  get 'orders_fullscreen' => 'orders#index_open'

  get 'time_stamps' => 'time_stamps#index'
  post 'time_stamps/export' => 'time_stamps#export'

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions', passwords: 'users/passwords' }
  resources :users, only: [:index, :update, :destroy]

  devise_scope :user do
    root to: "devise/sessions#new"
  end

end
