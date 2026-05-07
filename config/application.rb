require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Sona
  class Application < Rails::Application
    config.load_defaults 8.1
    config.time_zone = "America/Sao_Paulo"

    config.autoload_lib(ignore: %w[assets tasks])
  end
end
