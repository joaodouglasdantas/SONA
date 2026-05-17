require "net/http"
require "base64"
require "json"

class SimsAvatarService
  HF_MODEL   = "lllyasviel/sd-controlnet-canny"
  HF_IMG2IMG = "https://api-inference.huggingface.co/models/timbrooks/instruct-pix2pix"
  HF_TXT2IMG = "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0"

  SIMS_PROMPT = "a The Sims 4 video game character portrait, sims 4 art style, " \
    "large expressive eyes, smooth stylized skin, vibrant saturated colors, " \
    "soft cel-shaded lighting, clean polished look, sims 4 game screenshot, " \
    "official the sims 4 character render, high quality"

  NEGATIVE_PROMPT = "realistic, photograph, 3d render, ugly, blurry, low quality, " \
    "deformed, extra limbs, watermark, text"

  def initialize(user)
    @user  = user
    @token = ENV.fetch("HUGGINGFACE_TOKEN", nil)
  end

  def generate
    return { success: false, error: "Nenhuma foto encontrada." } unless @user.original_photo.attached?
    return { success: false, error: "Token do Hugging Face nao configurado." } if @token.blank?

    image_data    = @user.original_photo.download
    content_type  = @user.original_photo.content_type || "image/jpeg"

    response = call_img2img(image_data, content_type)
    result   = handle_response(response)

    if result[:not_available]
      response = call_txt2img
      result   = handle_response(response)
    end

    result
  rescue StandardError => e
    Rails.logger.error("SimsAvatarService error: #{e.class} - #{e.message}")
    { success: false, error: "Erro inesperado: #{e.message}" }
  end

  private

  def call_img2img(image_data, content_type)
    uri  = URI(HF_IMG2IMG)
    http = build_http(uri)

    req = Net::HTTP::Post.new(uri)
    req["Authorization"]    = "Bearer #{@token}"
    req["Content-Type"]     = "application/json"
    req["X-Wait-For-Model"] = "true"
    req["X-Use-Cache"]      = "false"
    req.body = {
      inputs: Base64.strict_encode64(image_data),
      parameters: {
        prompt:               SIMS_PROMPT,
        negative_prompt:      NEGATIVE_PROMPT,
        num_inference_steps:  20,
        image_guidance_scale: 1.5,
        guidance_scale:       7.5
      }
    }.to_json

    http.request(req)
  end

  def call_txt2img
    uri  = URI(HF_TXT2IMG)
    http = build_http(uri)

    req = Net::HTTP::Post.new(uri)
    req["Authorization"]    = "Bearer #{@token}"
    req["Content-Type"]     = "application/json"
    req["X-Wait-For-Model"] = "true"
    req["X-Use-Cache"]      = "false"
    req.body = {
      inputs: SIMS_PROMPT,
      parameters: {
        negative_prompt:     NEGATIVE_PROMPT,
        num_inference_steps: 25,
        guidance_scale:      7.5,
        width:               512,
        height:              512
      }
    }.to_json

    http.request(req)
  end

  def build_http(uri)
    http              = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = true
    http.read_timeout = 180
    http
  end

  def handle_response(response)
    Rails.logger.info("HF API response: #{response.code} - CT: #{response['content-type']}")

    case response
    when Net::HTTPSuccess
      content_type = response["content-type"] || "image/jpeg"
      if content_type.include?("application/json")
        body = safe_parse_json(response.body)
        error_msg = body.is_a?(Array) ? body.dig(0, "error") : body&.dig("error")
        return { success: false, error: error_msg || "Resposta inesperada do modelo. Tente novamente." }
      end
      attach_image(response.body, content_type)

    when Net::HTTPNotFound
      { success: false, error: "Modelo nao disponivel na API gratuita.", not_available: true }

    when Net::HTTPServiceUnavailable
      body = safe_parse_json(response.body)
      wait = body&.dig("estimated_time")&.round
      msg  = wait ? "Modelo carregando (aprox. #{wait}s). Tente novamente em instantes." : "Servico temporariamente indisponivel."
      { success: false, error: msg }

    when Net::HTTPTooManyRequests
      { success: false, error: "Limite de requisicoes atingido. Aguarde alguns minutos e tente novamente." }

    when Net::HTTPForbidden
      { success: false, error: "Token do Hugging Face invalido ou sem permissao para este modelo." }

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
    { success: false, error: "Erro ao salvar imagem: #{e.message}" }
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
