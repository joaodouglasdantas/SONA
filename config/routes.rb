Rails.application.routes.draw do
  get "dashboard/index"
  devise_for :users

  # devise_scope :user do
  #  root to: "devise/sessions#new"
  # end

  # Se meu usuário estiver autenticado, vai para o dashboard
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  # Se não estiver autenticado, vai para a tela de login
  unauthenticated do
    root to: "devise/sessions#new", as: :unauthenticated_root
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
