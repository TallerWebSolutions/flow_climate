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

      scope :pipefy do
        resources :pipefy_team_configs, only: %i[edit update], module: 'pipefy'
      end

      get 'search_for_projects/:status_filter', action: :search_for_projects, as: 'search_for_projects', on: :member
      get 'search_demands_to_flow_charts', action: :search_demands_to_flow_charts, as: 'search_demands_to_flow_charts', on: :member
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
      member do
        put :synchronize_pipefy
        patch :finish_project
        get :delivered_demands_csv
      end

      resources :project_results, except: %i[new create]

      resources :demands do
        put :synchronize_pipefy, on: :member

        resources :demand_blocks, only: [] do
          member do
            patch :activate
            patch :deactivate
          end
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

    resources :pipefy_configs, only: %i[new create destroy edit update], module: 'pipefy'

    resources :stages do
      member do
        patch 'associate_project/:project_id', action: :associate_project, as: 'associate_project'
        patch 'dissociate_project/:project_id', action: :dissociate_project, as: 'dissociate_project'
        patch :copy_projects_from
      end

      resources :demand_transitions, only: :destroy
      resources :stage_project_configs, only: %i[edit update]
    end
  end

  root 'companies#index'
end
