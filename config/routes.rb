# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  post 'pipefy_webhook' => 'webhook_integrations#pipefy_webhook'

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: { registrations: 'devise_custom/registrations' }

  resources :users, only: [] do
    collection do
      patch :activate_email_notifications
      patch :deactivate_email_notifications
    end
  end

  resources :companies, only: %i[show new create index edit update] do
    member do
      patch :add_user
      get :send_company_bulletin
      post :update_settings
    end

    resources :teams, only: %i[index show new create edit update] do
      resources :team_members, only: %i[new create edit update] do
        member do
          patch :activate
          patch :deactivate
        end
      end
      resources :pipefy_team_configs, only: %i[edit update]

      get 'search_for_projects/:status_filter', action: :search_for_projects, as: 'search_for_projects', on: :member
    end

    resources :financial_informations, only: %i[new create edit update destroy]
    resources :operation_results, only: %i[index destroy new create]

    resources :customers do
      get 'search_for_projects/:status_filter', action: :search_for_projects, as: 'search_for_projects', on: :member
    end

    resources :products do
      get 'products_for_customer/(:customer_id)', action: :products_for_customer, on: :collection
      get 'search_for_projects/:status_filter', action: :search_for_projects, as: 'search_for_projects', on: :member
    end

    resources :projects do
      resources :project_results do
        resources :demands do
          put :synchronize_pipefy, on: :member
        end
      end

      resources :project_risk_configs, only: %i[new create destroy] do
        member do
          patch :activate
          patch :deactivate
        end
      end

      get 'product_options_for_customer/(:customer_id)', action: :product_options_for_customer, on: :collection
      get 'search_for_projects/:status_filter', action: :search_for_projects, as: 'search_for_projects', on: :collection
    end

    resources :pipefy_configs, only: %i[new create destroy edit update]

    resources :stages, only: %i[new create edit update]
  end

  root 'companies#index'
end
