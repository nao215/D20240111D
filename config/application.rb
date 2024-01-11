require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module BaseSource
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = 'Asia/Saigon'
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :en
    config.i18n.available_locales = %i[en]
    config.paths.add 'lib', eager_load: true
    config.generators do |g|
      g.test_framework :rspec
    end
    config.active_job.queue_adapter = :sidekiq
    config.active_storage.variable_content_types << 'image/jpg'
    config.active_storage.silence_invalid_content_types_warning = true
  end
end
