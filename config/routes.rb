require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq' # Assuming this is part of the existing code that was not shown

  # Swagger documentation routes
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Health check route
  get '/health' => 'pages#health_check'

  # API namespace to group related routes together
  namespace :api do
    # Notes resource routes
    post '/notes', to: 'notes#create'
    get '/notes/search', to: 'notes#search'
    get '/notes', to: 'notes#index', as: 'list_user_notes'
    get '/notes/:id', to: 'notes#show' # Added from new code
    delete '/notes/:id', to: 'notes#destroy'
    put '/notes/:id/autosave', to: 'notes#autosave' # Already exists in both new and existing code
    put '/notes/:id', to: 'notes#update' # Existing code
  end

  # ... other routes that might exist in the application ...
end
