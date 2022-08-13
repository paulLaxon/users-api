# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      root to: redirect('/users')

      get 'users', to: 'users#index', as: 'users'
      post 'users', to: 'users#create', as: 'user'
      delete 'users', to: 'users#destroy'
    end
  end
end
