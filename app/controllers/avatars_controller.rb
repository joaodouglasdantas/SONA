class AvatarsController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def edit
  end

  def update
    if params[:remove_sims_avatar].present?
      current_user.sims_avatar.purge if current_user.sims_avatar.attached?
      current_user.update!(avatar_generation_status: "idle", avatar_generation_error: nil)
      redirect_to avatar_path, notice: "Avatar removido."
      return
    end

    if params.dig(:user, :original_photo).present?
      current_user.original_photo.attach(params[:user][:original_photo])
    end

    sim_name_value = params.dig(:user, :sim_name)
    current_user.update(sim_name: sim_name_value) if sim_name_value

    redirect_to avatar_path, notice: "Informacoes salvas."
  end

  def generate
    unless current_user.original_photo.attached?
      redirect_to edit_avatar_path, alert: "Envie uma foto primeiro."
      return
    end

    unless ENV["HUGGINGFACE_TOKEN"].present?
      redirect_to avatar_path, alert: "Token do Hugging Face nao configurado. Adicione HUGGINGFACE_TOKEN no .env"
      return
    end

    current_user.update!(
      avatar_generation_status: "generating",
      avatar_generation_error: nil
    )

    AvatarGenerationJob.perform_later(current_user.id)
    redirect_to avatar_path
  end

  def status
    current_user.reload
    render partial: "avatar_status_frame", layout: false
  end
end
