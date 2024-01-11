source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

# Gems for all environments
        gem 'multi_json'
        gem 'rswag', '~> 2.5.1'
gem 'active_storage_validations'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.4.2', require: false
gem 'cocoon'
# jitera-hook-for-devise
gem 'devise'
gem 'devise-i18n'
gem 'devise-i18n-views'
gem 'doorkeeper'
gem 'dotenv-rails'
gem 'enum_help'
# jitera-hook-for-fcm
gem 'image_processing', '~> 1.12.1'
gem 'jbuilder', '~> 2.11.5'
# jitera-hook-for-jwt
gem 'kaminari'
gem 'lograge'
gem 'pg', '~> 1.2'
gem 'puma', '~> 5.5.2'
gem 'pundit'
gem 'rack-cors'
gem 'rails', '~> 7.0.1'
gem 'rails-i18n'
gem 'redis', '4.5.1'
# jitera-hook-for-rollbar
gem 'sass-rails', '~> 5'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'simple_form'
gem 'slim'
gem 'turbo-rails'
# jitera-hook-for-twilio
gem 'importmap-rails', '~> 1.0'
# 1.13.0 above is not compatible with M1 Mac Docker environment, need to update docker image later
gem 'nokogiri', '1.12.5'
gem 'secure_headers'

group :production, :staging do
end

group :development, :test do
  gem 'brakeman'
  gem 'byebug', platforms: %w[mri mingw x64_mingw]
  gem 'faker'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-stack_explorer'
end
# since we need to run swaggerize command once in server (preview)
# https://github.com/rswag/rswag/issues/81#issuecomment-317534154
gem 'factory_bot_rails'
gem 'rspec'
gem 'rspec-rails', '~> 4.0.1'
gem 'shoulda-matchers'
gem 'validates_timeliness'
# swaggerize does not run spec just needded for documentation updates
group :development do
  gem 'letter_opener'
  gem 'listen', '~> 3.5'
  gem 'rails-erd'
  gem 'rubocop'
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'spring', '~> 3.0.0'
  gem 'spring-commands-rspec'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'database_cleaner-active_record'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: %w[mingw mswin x64_mingw jruby]
# jitera-hook-for-pdf-feature
