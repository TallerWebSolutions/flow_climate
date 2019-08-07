# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      resources :teams, only: [] do
        member do
          get :average_demand_cost
          get :items_in_wip
        end
      end

      resources :projects, only: [] do
        resources :flow_impacts, only: :create
      end

      resources :demands, only: :show
    end
  end

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

  resources :companies, except: :destroy do
    member do
      patch :add_user
      get :send_company_bulletin
      post :update_settings
      get :projects_tab
      get :strategic_chart_tab
      get :risks_tab
    end

    resources :teams do
      resources :slack_configurations, only: %i[new create edit update] do
        patch :toggle_active, on: :member
      end

      resources :memberships, except: :index

      get :replenishing_input, on: :member
    end

    resources :team_members, except: :index do
      member do
        patch :activate
        patch :deactivate
      end
    end

    resources :financial_informations, only: %i[new create edit update destroy]

    resources :customers

    resources :products do
      member do
        get :portfolio_units_tab
        get :projects_tab
        get :portfolio_demands_tab
        get :portfolio_charts_tab
      end

      get 'products_for_customer/(:customer_id)', action: :products_for_customer, on: :collection

      resources :portfolio_units, except: :index

      scope :jira do
        resources :jira_product_configs, only: %i[new create destroy], module: 'jira'
      end
    end

    resources :projects do
      resources :demands, except: %i[show destroy index] do
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

      resources :flow_impacts, except: :index do
        get :flow_impacts_tab, on: :collection
      end

      scope :jira do
        resources :jira_project_configs, only: %i[new create destroy edit], module: 'jira' do
          put :synchronize_jira, on: :member
        end
      end

      collection do
        get 'search_for_projects/:status_filter/:projects_ids', action: :search_for_projects, as: 'search_for_projects'
      end

      member do
        patch :finish_project

        get :statistics
        get :risk_drill_down
        get :closing_dashboard
        get :status_report_dashboard
        get :lead_time_dashboard

        patch :copy_stages_from
        patch 'associate_customer/:customer_id', action: :associate_customer, as: 'associate_customer'
        patch 'dissociate_customer/:customer_id', action: :dissociate_customer, as: 'dissociate_customer'
        patch 'associate_product/:product_id', action: :associate_product, as: 'associate_product'
        patch 'dissociate_product/:product_id', action: :dissociate_product, as: 'dissociate_product'
      end
    end

    resources :stages, except: :index do
      member do
        patch 'associate_project/:project_id', action: :associate_project, as: 'associate_project'
        patch 'dissociate_project/:project_id', action: :dissociate_project, as: 'dissociate_project'

        patch :copy_projects_from

        patch 'associate_team/:team_id', action: :associate_team, as: 'associate_team'
        patch 'dissociate_team/:team_id', action: :dissociate_team, as: 'dissociate_team'
      end

      post :import_from_jira, on: :collection

      resources :demand_transitions, only: :destroy
      resources :stage_project_configs, only: %i[edit update]
    end

    resources :demands, only: [] do
      delete :destroy_physically, on: :member

      collection do
        get 'demands_csv/(:demands_ids)', action: :demands_csv, as: 'demands_csv'
        get :demands_in_projects
        get 'search_demands'
      end
    end

    controller :charts do
      get 'build_operational_charts', action: :build_operational_charts
      get 'build_strategic_charts', action: :build_strategic_charts
      get 'statistics_charts', action: :statistics_charts
    end

    resources :demands, only: %i[show destroy]

    resources :flow_impacts, only: [:destroy] do
      collection do
        get :new_direct_link
        post :create_direct_link
        get 'demands_to_project/(:project_id)', action: :demands_to_project
      end
    end

    resources :demand_blocks, only: :index do
      collection do
        get :demands_blocks_tab
        get :demands_blocks_csv
      end
    end

    scope :jira do
      resources :jira_accounts, only: %i[new create destroy], module: 'jira'
    end
  end

  root 'home#show'
end
