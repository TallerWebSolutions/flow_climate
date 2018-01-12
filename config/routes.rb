# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: { registrations: 'devise_custom/registrations' }

  resources :users, only: [] do
    patch :change_current_company, on: :collection
  end

  resources :companies, only: %i[show new create index] do
    resources :financial_informations, only: %i[new create]
    resources :projects, only: %i[show index]
  end

  root 'companies#index'
end
