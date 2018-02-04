# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  get 'product/index'

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
    patch :add_user, on: :member

    resources :teams, only: %i[index show new create edit update] do
      resources :team_members, only: %i[new create edit update] do
        member do
          patch :activate
          patch :deactivate
        end
      end
      get 'search_for_projects/:status_filter', action: :search_for_projects, as: 'search_for_projects', on: :member
    end

    resources :financial_informations, only: %i[new create]
    resources :operation_results, only: %i[index destroy new create]

    resources :customers do
      get 'search_for_projects/:status_filter', action: :search_for_projects, as: 'search_for_projects', on: :member
    end

    resources :products do
      get 'products_for_customer/(:customer_id)', action: :products_for_customer, on: :collection
      get 'search_for_projects/:status_filter', action: :search_for_projects, as: 'search_for_projects', on: :member
    end

    resources :projects, only: %i[show index new create edit update] do
      resources :project_results do
        resources :demands, only: %i[new create destroy]
      end

      resources :project_risk_configs, only: %i[new create] do
        member do
          patch :activate
          patch :deactivate
        end
      end

      get 'product_options_for_customer/(:customer_id)', action: :product_options_for_customer, on: :collection
      get 'search_for_projects/:status_filter', action: :search_for_projects, as: 'search_for_projects', on: :collection
    end
  end

  root 'companies#index'
end
