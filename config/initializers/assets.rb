# Be sure to restart your server when you modify this file.

Rails.application.config.assets.version = "1.0"

# Adiciona pasta de emocoes ao asset load path
Rails.application.config.assets.paths << Rails.root.join("app/assets/emocoes")
