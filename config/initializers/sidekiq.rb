# typed: strict
unless Rails.env.test?
  redis_conn = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379') }

  Sidekiq.configure_server do |config|
    config.redis = redis_conn
  end

  Sidekiq.configure_client do |config|
    config.redis = redis_conn
  end
end
