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
    resources :teams, only: %i[index show new create] do
      resources :team_members, only: %i[new create edit update]
    end

    resources :financial_informations, only: %i[new create]
    resources :operation_results, only: %i[index destroy new create]

    resources :projects, only: %i[show index new create edit update] do
      resources :project_results, only: %i[new create destroy]
    end
  end

  root 'companies#index'
end
