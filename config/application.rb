require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ariaguma
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    config.autoload_paths << Rails.root.join('app/lib')

    config.assets.paths << Rails.root.join("app/javascript")

    config.autoload_paths += %W(#{config.root}/app/lib)

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

#    config.active_record.encryption.primary_key = Rails.application.credentials.dig(:active_record_encryption, :primary_key)
#    config.active_record.encryption.deterministic_key = Rails.application.credentials.dig(:active_record_encryption, :deterministic_key)
#    config.active_record.encryption.key_derivation_salt = Rails.application.credentials.dig(:active_record_encryption, :key_derivation_salt)

    config.active_record.encryption.primary_key = ENV["RAILS_MASTER_KEY"]
    config.active_record.encryption.deterministic_key = ENV["DETERMINISTIC_KEY"]
    config.active_record.encryption.key_derivation_salt = ENV["KEY_DERIVATION_SALT"]

    config.i18n.default_locale = :ja # バリデーションエラーメッセージの国際化（i18n）対応

    # ActiveRecord Encryption cache を無効化
    config.active_record.encryption.cache = nil

  end
end
