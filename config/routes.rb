Rails.application.routes.draw do

  resources :legal_health_evals
  resources :legal_health_params
  resources :legal_health_topics
  resources :legal_health_customers
  get 'legal_health_scores' => 'legal_health_scores#index'
  get 'legal_health_scores/:customer_id/edit' => 'legal_health_scores#edit', as: 'edit_legal_health_score'
  get 'legal_health_scores/:customer_id' => 'legal_health_scores#show', as: 'legal_health_score'

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
  post 'members/:id/create_user_from_member' => 'members#create_user_from_member', as: 'create_user_from_member'
  resources :members
  resources :scan_events, only: [:index, :show, :edit, :create, :update, :destroy]
  get 'feedbacks/extern', to: redirect('feedbacks/extern/new')
  get 'feedbacks/extern/new' => 'feedbacks#new_extern'
  post 'feedbacks/extern' => 'feedbacks#create_extern'
  get 'feedbacks/extern/success' => 'feedbacks#success_extern'
  post 'feedbacks/export' => 'feedbacks#export'
  resources :feedbacks
  resources :orders, only: [:index, :show, :update, :destroy]
  get 'orders_fullscreen' => 'orders#index_open'

  resources :time_stamps, only: [:index, :new, :edit, :create, :update, :destroy]
  post 'time_stamps/export' => 'time_stamps#export'

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions', passwords: 'users/passwords' }
  resources :users, only: [:index, :update, :destroy]

  devise_scope :user do
    root to: "devise/sessions#new"
  end

end
