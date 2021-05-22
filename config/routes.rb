Rails.application.routes.draw do
  get 'home' => 'home#index'

  resources :devices
  get 'members/extern', to: redirect('members/extern/new')
  get 'members/extern/new' => 'members#new_extern'
  post 'members/extern' => 'members#create_extern'
  get 'members/extern/success' => 'members#success_extern'
  resources :members
  resources :scan_events, only: [:index, :show, :create, :update, :destroy]
  get 'feedbacks/extern', to: redirect('feedbacks/extern/new')
  get 'feedbacks/extern/new' => 'feedbacks#new_extern'
  post 'feedbacks/extern' => 'feedbacks#create_extern'
  get 'feedbacks/extern/success' => 'feedbacks#success_extern'
  resources :feedbacks

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions', passwords: 'users/passwords' }
  resources :users, only: [:index, :update, :destroy]

  devise_scope :user do
    root to: "devise/sessions#new"
  end

end
