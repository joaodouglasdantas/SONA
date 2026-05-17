class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Definindo o hash de cores para cada humor
    @mood_colors_dash = {
      "feliz" => "var(--sims-green)",
      "triste" => "var(--sims-blue)",
      "ansioso" => "var(--sims-orange)",
      "irritado" => "var(--sims-red)"
      # Adicione outros humores aqui se precisar
    }

    # Definindo os textos amigáveis para cada humor
    @mood_labels_dash = {
      "feliz" => "Feliz",
      "triste" => "Triste",
      "ansioso" => "Ansioso",
      "irritado" => "Irritado"
      # Adicione outros humores aqui se precisar
    }
  end
end