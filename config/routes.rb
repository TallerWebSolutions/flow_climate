# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  get 'product/index'

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: { registrations: 'devise_custom/registrations' }

  resources :companies, only: %i[show new create index] do
    resources :teams, only: %i[index show new create edit update] do
      resources :team_members, only: %i[new create edit update] do
        member do
          patch :activate
          patch :deactivate
        end
      end
    end

    resources :financial_informations, only: %i[new create]
    resources :operation_results, only: %i[index destroy new create]

    resources :customers, only: %i[index new create edit update show]
    resources :products, only: %i[index new create edit update show]

    resources :projects, only: %i[show index new create edit update] do
      resources :project_results, only: %i[new create destroy edit update]
    end
  end

  root 'companies#index'
end
