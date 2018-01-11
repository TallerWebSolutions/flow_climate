# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: { registrations: 'devise_custom/registrations' }

  resources :companies, only: [:show]

  root 'companies#show'
end
