Rails.application.routes.draw do
  devise_for :users

  get "dashboard", to: "dashboard#index"
  resources :emotions

  resource :avatar, only: [ :show, :edit, :update ]
  post "avatar/generate", to: "avatars#generate", as: :generate_avatar
  get  "avatar/status",   to: "avatars#status",   as: :avatar_status

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  match "*path", to: "errors#routing", via: :all
end
