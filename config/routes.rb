# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  controller :webhook_integrations do
    post 'jira_webhook'
    post 'jira_delete_card_webhook'
  end

  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: { registrations: 'devise_custom/registrations' }

  controller :home do
    get :show
    get :no_company
  end

  controller :exports do
    get :request_project_information
    post :process_requested_information

    post :send_csv_data_by_email
  end

  controller :plans do
    get :no_plan
    post :plan_choose
  end

  resources :users, only: %i[show index update] do
    collection do
      patch :activate_email_notifications
      patch :deactivate_email_notifications
    end
    patch :toggle_admin, on: :member

    resources :user_plans, only: [] do
      member do
        patch :activate_user_plan
        patch :deactivate_user_plan
        patch :pay_plan
        patch :unpay_plan
      end
    end
  end

  resources :companies, only: %i[show new create index edit update] do
    member do
      patch :add_user
      get :send_company_bulletin
      post :update_settings
    end

    resources :teams, only: %i[index show new create edit update] do
      get :replenishing_input, on: :member

      resources :team_members, only: %i[new create edit update] do
        member do
          patch :activate
          patch :deactivate
        end
      end
    end

    resources :financial_informations, only: %i[new create edit update destroy]

    resources :customers

    resources :products do
      get 'products_for_customer/(:customer_id)', action: :products_for_customer, on: :collection
    end

    resources :projects do
      resources :demands, except: %i[show destroy] do
        put :synchronize_jira, on: :member

        resources :demand_blocks, only: %i[edit update] do
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

      resources :demand_blocks, only: :index

      scope :jira do
        resources :project_jira_configs, only: %i[new create destroy], module: 'jira'
      end

      collection do
        get 'product_options_for_customer/(:customer_id)', action: :product_options_for_customer
        get 'search_for_projects/:status_filter', action: :search_for_projects, as: 'search_for_projects'
      end

      member do
        put :synchronize_jira
        patch :finish_project
        get :statistics
        patch :copy_stages_from
        get :statistics_tab
      end
    end

    resources :stages do
      member do
        patch 'associate_project/:project_id', action: :associate_project, as: 'associate_project'
        patch 'dissociate_project/:project_id', action: :dissociate_project, as: 'dissociate_project'
        patch :copy_projects_from
      end

      resources :demand_transitions, only: :destroy
      resources :stage_project_configs, only: %i[edit update]
    end

    resources :demands, only: [] do
      collection do
        get 'demands_csv/(:demands_ids)', action: :demands_csv, as: 'demands_csv'
        get :demands_in_projects
        get 'search_demands_by_flow_status'
      end
    end

    controller :charts do
      get 'build_operational_charts', action: :build_operational_charts # team product customer project
      get 'build_strategic_charts', action: :build_strategic_charts # team company
      get 'build_status_report_charts', action: :build_status_report_charts # team product customer project
    end

    resources :demands, only: %i[show destroy]
  end

  root 'home#show'
end
