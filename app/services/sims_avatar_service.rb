require "net/http"
require "base64"
require "json"

class SimsAvatarService
  HF_MODEL   = "timbrooks/instruct-pix2pix"
  HF_API_URL = "https://api-inference.huggingface.co/models/#{HF_MODEL}"

  SIMS_PROMPT = "Transform this person into a The Sims 4 video game character. " \
    "Sims 4 art style: smooth stylized skin (not realistic), large expressive eyes, " \
    "vibrant and saturated colors, soft cel-shaded lighting, clean and polished look. " \
    "Keep the person's recognizable features: skin tone, hair color, face shape. " \
    "Background should be a simple Sims 4 room. " \
    "The result must look like a real screenshot from The Sims 4 game."

  def initialize(user)
    @user  = user
    @token = ENV.fetch("HUGGINGFACE_TOKEN", nil)
  end

  def generate
    return { success: false, error: "Nenhuma foto encontrada." } unless @user.original_photo.attached?
    return { success: false, error: "Token do Hugging Face nao configurado. Adicione HUGGINGFACE_TOKEN no .env" } if @token.blank?

    image_data = @user.original_photo.download
    response   = call_hf_api(image_data)

    handle_response(response)
  rescue StandardError => e
    Rails.logger.error("SimsAvatarService error: #{e.class} - #{e.message}")
    { success: false, error: "Erro inesperado: #{e.message}" }
  end

  private

  def call_hf_api(image_data)
    uri  = URI(HF_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = true
    http.read_timeout = 120

    req = Net::HTTP::Post.new(uri)
    req["Authorization"]    = "Bearer #{@token}"
    req["Content-Type"]     = "application/json"
    req["X-Wait-For-Model"] = "true"

    req.body = {
      inputs:     Base64.strict_encode64(image_data),
      parameters: { prompt: SIMS_PROMPT }
    }.to_json

    http.request(req)
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      content_type = response["content-type"] || "image/jpeg"
      if content_type.include?("application/json")
        return { success: false, error: "Resposta inesperada do modelo. Tente novamente." }
      end
      attach_image(response.body, content_type)

    when Net::HTTPServiceUnavailable
      body = safe_parse_json(response.body)
      wait = body&.dig("estimated_time")&.round
      msg  = wait ? "Modelo carregando, tente em #{wait} segundos." : "Servico temporariamente indisponivel."
      { success: false, error: msg }

    when Net::HTTPTooManyRequests
      { success: false, error: "Limite de requisicoes atingido. Aguarde alguns minutos." }

    else
      body = safe_parse_json(response.body)
      msg  = body&.dig("error") || "Erro HTTP #{response.code}: #{response.message}"
      { success: false, error: msg }
    end
  end

  def attach_image(image_bytes, content_type)
    ext      = content_type.include?("png") ? ".png" : ".jpg"
    tempfile = Tempfile.new(["sims_avatar_output", ext])
    tempfile.binmode
    tempfile.write(image_bytes)
    tempfile.rewind

    @user.sims_avatar.attach(
      io:           tempfile,
      filename:     "sims_avatar_#{@user.id}#{ext}",
      content_type: content_type.split(";").first.strip
    )

    { success: true }
  rescue StandardError => e
    { success: false, error: "Erro ao salvar imagem gerada: #{e.message}" }
  ensure
    tempfile&.close
    tempfile&.unlink
  end

  def safe_parse_json(body)
    JSON.parse(body)
  rescue JSON::ParserError
    nil
  end
end
