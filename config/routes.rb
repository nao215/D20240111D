require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/api/notes', to: 'api/notes#index', as: 'list_user_notes'
  delete '/api/notes/:id', to: 'notes#destroy'
  put '/api/notes/:id/autosave', to: 'notes#autosave'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
end
