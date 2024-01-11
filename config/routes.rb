require 'sidekiq/web'

Rails.application.routes.draw do
  # Mounting Sidekiq Web UI
  mount Sidekiq::Web => '/sidekiq'

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
    get '/notes/:id', to: 'notes#show'
    delete '/notes/:id', to: 'notes#destroy'
    put '/notes/:id/autosave', to: 'notes#autosave'
    put '/notes/:id', to: 'notes#update'
  end

  # ... other routes that might exist in the application ...
end
