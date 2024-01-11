Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: true, logger: (-> { Rails.logger }) do
  allow do
    origins request_source_origin
    resource '/api/*', headers: :any, methods: %i[get post put patch delete options head], credentials: true,
                       expose: ['Content-Disposition']
    resource '/oauth/*', headers: :any, methods: %i[get post put patch delete options head], credentials: true,
                         expose: ['Content-Disposition']
    resource '/rails/active_storage/*', headers: :any, methods: %i[get], credentials: true,
                                        expose: ['Content-Disposition']
  end
end

def request_source_origin
  # Default host localhost and default port 8080
  urls = %w[http://localhost:8080]
  urls << "https://#{ENV['HOST_URL']}" if ENV['HOST_URL'].present?
  urls << "https://#{ENV['FRONTEND_HOST']}" if ENV['FRONTEND_HOST'].present?
  urls
end
