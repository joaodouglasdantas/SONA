Rails.application.routes.draw do
  get "emotions/index"
  get "emotions/new"
  get "emotions/create"
  get "emotions/show"
  devise_for :users

  get "dashboard", to: "dashboard#index"

  # devise_scope :user do
  #  root to: "devise/sessions#new"
  # end

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
    resources :emotions, only: [ :index, :new, :create, :show ]
  end

  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  match "*path", to: "errors#routing", via: :all
end
