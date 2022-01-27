# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  options '/graphql', to: 'graphql#execute'
  post '/graphql', to: 'graphql#execute'

  namespace 'api' do
    namespace 'v1' do
      resources :companies, only: :show do
        get :active_projects, on: :member
      end

      resources :teams, only: [] do
        member do
          get :average_demand_cost
          get :items_in_wip
          get :items_delivered_last_week
        end
      end

      resources :projects, only: :show

      resources :demands, only: :show

      resources :flow_events, only: %i[new create] do
        get :opened_events, on: :collection
      end
    end
  end

  controller :webhook_integrations do
    post 'jira_webhook'
    post 'jira_delete_card_webhook'
  end

  devise_for :users, controllers: { registrations: 'devise_custom/users/registrations' }
  devise_for :devise_customers, controllers: { registrations: 'devise_custom/devise_customers/registrations' }

  authenticated :user do
    mount Sidekiq::Web => '/sidekiq'

    root 'users#home', as: :user_home
  end

  authenticated :devise_customer do
    root 'devise_customers#home', as: :devise_customer_home
  end

  unauthenticated do
    root 'home#show'
  end

  controller :home do
    get :show
  end

  controller :plans do
    get :no_plan
    post :plan_choose
  end

  resources :users, only: %i[show edit update] do
    collection do
      get :admin_dashboard
      patch :activate_email_notifications
      patch :deactivate_email_notifications
    end

    member do
      get :companies
      patch :toggle_admin
    end

    resources :user_plans, only: [:index] do
      member do
        patch :activate_user_plan
        patch :deactivate_user_plan
        patch :pay_plan
        patch :unpay_plan
      end
    end

    resources :companies, only: [] do
      resources :user_company_roles, only: %i[new create edit update]
    end
  end

  resources :devise_customers, only: :show

  resources :score_matrices, only: :show do
    member do
      get :customer_dimension
      get :service_provider_dimension
      get :ordered_demands_list
    end
  end

  resources :demand_score_matrices, only: %i[create destroy] do
    post :create_from_sheet, on: :collection
    delete :destroy_from_sheet, on: :member
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

    resources :azure_accounts, only: [], module: 'azure' do
      post :synchronize_azure, on: :collection
    end

    resources :teams do
      resources :slack_configurations, except: :show do
        patch :toggle_active, on: :member
      end

      resources :memberships do
        get :search_memberships, on: :collection
      end

      resources :team_resource_allocations, only: %i[new create destroy]

      resources :replenishing_consolidations, only: [:index] do
        put :refresh_cache, on: :collection
      end

      member do
        get :team_projects_tab
        get :dashboard_tab
        get :dashboard_page_two
        get :dashboard_page_three
        get :dashboard_page_four
        get :dashboard_page_five

        patch :update_cache
      end
    end

    resources :team_members, except: :index do
      member do
        get :associate_user
        get :dissociate_user
      end

      get :search_team_members, on: :collection
      get :pairings, on: :member
    end

    resources :financial_informations, only: %i[new create edit update destroy]

    resources :customers do
      member do
        post :add_user_to_customer
        patch :update_cache
      end
      resources :contracts, except: %i[index] do
        patch :update_consolidations, on: :member
      end
    end

    resources :team_resources, only: %i[new create destroy]

    resources :products do
      member do
        get :portfolio_units_tab
        get :projects_tab
        get :portfolio_charts_tab
        get :risk_reviews_tab
        get :service_delivery_reviews_tab
      end

      get 'products_for_customer/(:customer_id)', action: :products_for_customer, on: :collection

      resources :portfolio_units, except: :index
      resources :risk_reviews, except: :index do
        resources :risk_review_action_items, only: %w[new create destroy]
      end
      resources :service_delivery_reviews, except: :index do
        patch :refresh, on: :member
      end

      scope :jira do
        resources :jira_product_configs, only: %i[new create destroy], module: 'jira'
      end

      resources :score_matrix_questions, except: :index do
        resources :score_matrix_answers, only: %i[create destroy]
      end
    end

    resources :projects do
      resources :demands, except: %i[show destroy index] do
        resources :demand_blocks, only: %i[edit update] do
          member do
            patch :activate
            patch :deactivate
          end
        end
      end

      resources :project_risk_configs, except: %i[edit update show] do
        member do
          patch :activate
          patch :deactivate
        end
      end

      resources :stage_project_configs, only: %i[index destroy]
      resources :project_risk_alerts, only: %i[index]

      scope :jira do
        resources :jira_project_configs, only: %i[new create destroy index], module: 'jira' do
          put :synchronize_jira, on: :member
        end
      end

      member do
        get :tasks_tab

        get :statistics
        get :risk_drill_down
        get :closing_dashboard
        get :status_report_dashboard
        get :lead_time_dashboard
        get :statistics_tab

        patch :copy_stages_from
        patch :finish_project
        patch 'associate_customer/:customer_id', action: :associate_customer, as: 'associate_customer'
        patch 'dissociate_customer/:customer_id', action: :dissociate_customer, as: 'dissociate_customer'
        patch 'associate_product/:product_id', action: :associate_product, as: 'associate_product'
        patch 'dissociate_product/:product_id', action: :dissociate_product, as: 'dissociate_product'
        patch :update_consolidations
      end

      collection do
        get :search_projects
        get :search_projects_by_team
        get :running_projects_charts
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

    resources :demands, only: %i[show destroy index] do
      member do
        delete :destroy_physically
        get :score_research
        put :synchronize_jira
      end

      collection do
        post 'demands_csv/(:demands_ids)', action: :demands_csv, as: 'demands_csv'
        get 'demands_list_by_ids', action: :demands_list_by_ids, as: :demands_list_by_ids
        get 'search_demands'
        get 'demands_charts'
      end

      resources :demand_transitions, except: %i[destroy index]
      resources :item_assignments, only: :destroy

      resources :demand_efforts, only: :index
    end

    controller :charts do
      get 'build_strategic_charts', action: :build_strategic_charts
    end

    resources :demand_blocks, only: :index do
      collection do
        get :demand_blocks_csv

        post :search
      end
    end

    scope :jira do
      resources :jira_accounts, only: %i[new create destroy show], module: 'jira' do
        resources :jira_custom_field_mappings, except: :index
      end
    end

    resources :flow_events
  end
end
