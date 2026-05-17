class AvatarGenerationJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    return unless user.avatar_generation_status == "generating"

    service = SimsAvatarService.new(user)
    result  = service.generate

    if result[:success]
      user.update!(
        avatar_generation_status: "done",
        avatar_generation_error: nil
      )
    else
      user.update!(
        avatar_generation_status: "failed",
        avatar_generation_error: result[:error]
      )
    end
  rescue ActiveRecord::RecordNotFound
    nil
  rescue => e
    Rails.logger.error("AvatarGenerationJob error: #{e.class} - #{e.message}")
    User.find_by(id: user_id)&.update(
      avatar_generation_status: "failed",
      avatar_generation_error: "Erro interno: #{e.message}"
    )
  end
end
