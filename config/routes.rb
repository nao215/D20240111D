require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  namespace :api do
    post '/notes', to: 'notes#create'
    get '/notes/search', to: 'notes#search'
    get '/notes', to: 'notes#index', as: 'list_user_notes'
    get '/notes/:id', to: 'notes#show' # Added from new code
    delete '/notes/:id', to: 'notes#destroy'
    put '/notes/:id/autosave', to: 'notes#autosave' # Already exists in both new and existing code
    put '/notes/:id', to: 'notes#update'
  end

  # ... other routes ...
end
