class ErrorsController < ApplicationController
  def routing
    if user_signed_in? # É um helper do Devise que retorna true se existe um usuário logado na sessão atual
      redirect_to authenticated_root_path # Esse helper aponta para a rota que eu defini como authenticated_root (no caso, o dashboard#index)
    else
      redirect_to new_user_session_path
    end
  end
end
