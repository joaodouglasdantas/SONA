class EmotionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @emotions = current_user.emotions.order(created_at: :desc)
  end

  def new
    @emotion = Emotion.new
  end

  def create
    @emotion = current_user.emotions.build(emotion_params)
    if @emotion.save
      redirect_to emotions_path, notice: "Emoção registrada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @emotion = current_user.emotions.find(params[:id])
  end

  def edit
    @emotion = current_user.emotions.find(params[:id])
  end

  def update
    @emotion = current_user.emotions.find(params[:id])
    if @emotion.update(emotion_params)
      redirect_to emotion_path, notice: "Emoção atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @emotion = current_user.emotions.find(params[:id])
    @emotion.destroy
    redirect_to emotions_path, notice: "Emoção excluída com sucesso!"
  end

  private

  def emotion_params
    params.require(:emotion).permit(:mood, :intensity, :note)
  end
end
