# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_02_14_141346) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "azure_accounts", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "username", null: false
    t.string "encrypted_password", null: false
    t.string "azure_organization", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "azure_work_item_query"
    t.index ["company_id"], name: "index_azure_accounts_on_company_id"
  end

  create_table "azure_custom_fields", force: :cascade do |t|
    t.integer "azure_account_id", null: false
    t.integer "custom_field_type", default: 0, null: false
    t.string "custom_field_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "azure_product_configs", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "azure_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["azure_account_id"], name: "index_azure_product_configs_on_azure_account_id"
    t.index ["product_id"], name: "index_azure_product_configs_on_product_id"
  end

  create_table "azure_projects", force: :cascade do |t|
    t.integer "azure_team_id", null: false
    t.string "project_id", null: false
    t.string "project_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["azure_team_id"], name: "index_azure_projects_on_azure_team_id"
  end

  create_table "azure_teams", force: :cascade do |t|
    t.integer "azure_product_config_id", null: false
    t.string "team_id", null: false
    t.string "team_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["azure_product_config_id"], name: "index_azure_teams_on_azure_product_config_id"
  end

  create_table "class_of_service_change_histories", force: :cascade do |t|
    t.integer "demand_id", null: false
    t.datetime "change_date", precision: nil, null: false
    t.integer "from_class_of_service"
    t.integer "to_class_of_service", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["demand_id", "change_date"], name: "cos_history_unique", unique: true
    t.index ["demand_id"], name: "index_class_of_service_change_histories_on_demand_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "abbreviation", null: false
    t.integer "customers_count", default: 0
    t.string "slug"
    t.string "api_token", null: false
    t.index ["abbreviation"], name: "index_companies_on_abbreviation", unique: true
    t.index ["api_token"], name: "index_companies_on_api_token", unique: true
    t.index ["slug"], name: "index_companies_on_slug", unique: true
  end

  create_table "company_settings", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "max_active_parallel_projects", null: false
    t.decimal "max_flow_pressure", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["company_id"], name: "index_company_settings_on_company_id"
  end

  create_table "contract_consolidations", force: :cascade do |t|
    t.integer "contract_id", null: false
    t.date "consolidation_date", null: false
    t.decimal "operational_risk_value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "min_monte_carlo_weeks", default: 0
    t.integer "max_monte_carlo_weeks", default: 0
    t.integer "monte_carlo_duration_p80_weeks", default: 0
    t.integer "estimated_hours_per_demand"
    t.integer "real_hours_per_demand"
    t.decimal "development_consumed_hours", default: "0.0", null: false
    t.decimal "design_consumed_hours", default: "0.0", null: false
    t.decimal "management_consumed_hours", default: "0.0", null: false
    t.decimal "development_consumed_hours_in_month", default: "0.0", null: false
    t.decimal "design_consumed_hours_in_month", default: "0.0", null: false
    t.decimal "management_consumed_hours_in_month", default: "0.0", null: false
    t.index ["consolidation_date"], name: "index_contract_consolidations_on_consolidation_date"
    t.index ["contract_id", "consolidation_date"], name: "idx_contract_consolidation_unique", unique: true
    t.index ["contract_id"], name: "index_contract_consolidations_on_contract_id"
  end

  create_table "contract_estimation_change_histories", force: :cascade do |t|
    t.integer "contract_id", null: false
    t.datetime "change_date", precision: nil, null: false
    t.integer "hours_per_demand", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contracts", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "customer_id", null: false
    t.integer "contract_id"
    t.date "start_date", null: false
    t.date "end_date"
    t.integer "renewal_period", default: 0, null: false
    t.boolean "automatic_renewal", default: false
    t.integer "total_hours", null: false
    t.integer "total_value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hours_per_demand", default: 1, null: false
    t.index ["contract_id"], name: "index_contracts_on_contract_id"
    t.index ["customer_id"], name: "index_contracts_on_customer_id"
    t.index ["product_id"], name: "index_contracts_on_product_id"
  end

  create_table "customer_consolidations", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.date "consolidation_date", null: false
    t.boolean "last_data_in_week", default: false
    t.boolean "last_data_in_month", default: false
    t.boolean "last_data_in_year", default: false
    t.decimal "consumed_hours", default: "0.0"
    t.decimal "consumed_hours_in_month", default: "0.0"
    t.decimal "average_consumed_hours_in_month", default: "0.0"
    t.decimal "flow_pressure", default: "0.0"
    t.decimal "lead_time_p80", default: "0.0"
    t.decimal "lead_time_p80_in_month", default: "0.0"
    t.decimal "value_per_demand", default: "0.0"
    t.decimal "value_per_demand_in_month", default: "0.0"
    t.decimal "hours_per_demand", default: "0.0"
    t.decimal "hours_per_demand_in_month", default: "0.0"
    t.integer "qty_demands_created", default: 0
    t.integer "qty_demands_committed", default: 0
    t.integer "qty_demands_finished", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "development_consumed_hours", default: "0.0", null: false
    t.decimal "design_consumed_hours", default: "0.0", null: false
    t.decimal "management_consumed_hours", default: "0.0", null: false
    t.decimal "development_consumed_hours_in_month", default: "0.0", null: false
    t.decimal "design_consumed_hours_in_month", default: "0.0", null: false
    t.decimal "management_consumed_hours_in_month", default: "0.0", null: false
    t.index ["customer_id", "consolidation_date"], name: "customer_consolidation_unique", unique: true
    t.index ["customer_id"], name: "index_customer_consolidations_on_customer_id"
    t.index ["last_data_in_month"], name: "index_customer_consolidations_on_last_data_in_month"
    t.index ["last_data_in_week"], name: "index_customer_consolidations_on_last_data_in_week"
    t.index ["last_data_in_year"], name: "index_customer_consolidations_on_last_data_in_year"
  end

  create_table "customers", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "products_count", default: 0
    t.integer "projects_count", default: 0
    t.integer "customer_id"
    t.index ["company_id", "name"], name: "index_customers_on_company_id_and_name", unique: true
    t.index ["company_id"], name: "index_customers_on_company_id"
    t.index ["customer_id"], name: "index_customers_on_customer_id"
  end

  create_table "customers_devise_customers", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.integer "devise_customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "devise_customer_id"], name: "idx_customers_devise_customer_unique", unique: true
    t.index ["customer_id"], name: "index_customers_devise_customers_on_customer_id"
    t.index ["devise_customer_id"], name: "index_customers_devise_customers_on_devise_customer_id"
  end

  create_table "customers_projects", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["customer_id", "project_id"], name: "index_customers_projects_on_customer_id_and_project_id", unique: true
    t.index ["customer_id"], name: "index_customers_projects_on_customer_id"
    t.index ["project_id"], name: "index_customers_projects_on_project_id"
  end

  create_table "demand_block_notifications", force: :cascade do |t|
    t.integer "demand_block_id", null: false
    t.integer "block_state", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["block_state"], name: "index_demand_block_notifications_on_block_state"
    t.index ["demand_block_id"], name: "index_demand_block_notifications_on_demand_block_id"
  end

  create_table "demand_blocks", force: :cascade do |t|
    t.integer "demand_id", null: false
    t.datetime "block_time", precision: nil, null: false
    t.datetime "unblock_time", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active", default: true, null: false
    t.integer "block_type", default: 0, null: false
    t.datetime "discarded_at", precision: nil
    t.integer "stage_id"
    t.string "block_reason"
    t.integer "blocker_id", null: false
    t.integer "unblocker_id"
    t.string "unblock_reason"
    t.integer "risk_review_id"
    t.decimal "block_working_time_duration"
    t.integer "lock_version"
    t.index ["blocker_id"], name: "index_demand_blocks_on_blocker_id"
    t.index ["demand_id"], name: "index_demand_blocks_on_demand_id"
    t.index ["discarded_at"], name: "index_demand_blocks_on_discarded_at"
    t.index ["risk_review_id"], name: "index_demand_blocks_on_risk_review_id"
    t.index ["stage_id"], name: "index_demand_blocks_on_stage_id"
    t.index ["unblocker_id"], name: "index_demand_blocks_on_unblocker_id"
  end

  create_table "demand_comments", force: :cascade do |t|
    t.integer "demand_id", null: false
    t.datetime "comment_date", precision: nil, null: false
    t.string "comment_text", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "team_member_id"
    t.datetime "discarded_at", precision: nil
    t.index ["demand_id"], name: "index_demand_comments_on_demand_id"
    t.index ["discarded_at"], name: "index_demand_comments_on_discarded_at"
    t.index ["team_member_id"], name: "index_demand_comments_on_team_member_id"
  end

  create_table "demand_efforts", force: :cascade do |t|
    t.integer "item_assignment_id", null: false
    t.integer "demand_transition_id", null: false
    t.integer "demand_id", null: false
    t.boolean "main_effort_in_transition", default: false, null: false
    t.boolean "automatic_update", default: true, null: false
    t.datetime "start_time_to_computation", precision: nil, null: false
    t.datetime "finish_time_to_computation", precision: nil, null: false
    t.decimal "effort_value", default: "0.0", null: false
    t.decimal "management_percentage", default: "0.0", null: false
    t.decimal "pairing_percentage", default: "0.0", null: false
    t.decimal "stage_percentage", default: "0.0", null: false
    t.decimal "total_blocked", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "effort_with_blocks", default: "0.0"
    t.integer "lock_version"
    t.index ["demand_id"], name: "index_demand_efforts_on_demand_id"
    t.index ["demand_transition_id"], name: "index_demand_efforts_on_demand_transition_id"
    t.index ["item_assignment_id", "demand_transition_id", "start_time_to_computation"], name: "idx_demand_efforts_unique", unique: true
    t.index ["item_assignment_id"], name: "index_demand_efforts_on_item_assignment_id"
  end

  create_table "demand_score_matrices", force: :cascade do |t|
    t.integer "demand_id", null: false
    t.integer "user_id", null: false
    t.integer "score_matrix_answer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["demand_id"], name: "index_demand_score_matrices_on_demand_id"
    t.index ["score_matrix_answer_id"], name: "index_demand_score_matrices_on_score_matrix_answer_id"
    t.index ["user_id"], name: "index_demand_score_matrices_on_user_id"
  end

  create_table "demand_transitions", force: :cascade do |t|
    t.integer "demand_id", null: false
    t.integer "stage_id", null: false
    t.datetime "last_time_in", precision: nil, null: false
    t.datetime "last_time_out", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "discarded_at", precision: nil
    t.boolean "transition_notified", default: false, null: false
    t.integer "team_member_id"
    t.integer "lock_version"
    t.index ["demand_id", "stage_id", "last_time_in"], name: "idx_transitions_unique", unique: true
    t.index ["demand_id"], name: "index_demand_transitions_on_demand_id"
    t.index ["discarded_at"], name: "index_demand_transitions_on_discarded_at"
    t.index ["stage_id"], name: "index_demand_transitions_on_stage_id"
    t.index ["team_member_id"], name: "index_demand_transitions_on_team_member_id"
    t.index ["transition_notified"], name: "index_demand_transitions_on_transition_notified"
  end

  create_table "demands", force: :cascade do |t|
    t.string "external_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "demand_type", null: false
    t.string "demand_url"
    t.datetime "commitment_date", precision: nil
    t.datetime "end_date", precision: nil
    t.datetime "created_date", precision: nil, null: false
    t.string "external_url"
    t.integer "class_of_service", default: 0, null: false
    t.integer "project_id"
    t.decimal "effort_downstream", default: "0.0"
    t.decimal "effort_upstream", default: "0.0"
    t.decimal "leadtime"
    t.boolean "manual_effort", default: false
    t.integer "total_queue_time", default: 0
    t.integer "total_touch_time", default: 0
    t.string "demand_title"
    t.datetime "discarded_at", precision: nil
    t.string "slug"
    t.integer "company_id", null: false
    t.integer "portfolio_unit_id"
    t.integer "product_id"
    t.integer "team_id", null: false
    t.decimal "cost_to_project", default: "0.0"
    t.decimal "total_bloked_working_time", default: "0.0"
    t.decimal "total_touch_blocked_time", default: "0.0"
    t.integer "risk_review_id"
    t.decimal "demand_score", default: "0.0"
    t.integer "service_delivery_review_id"
    t.integer "current_stage_id"
    t.integer "customer_id"
    t.string "demand_tags", default: [], array: true
    t.integer "contract_id"
    t.decimal "effort_development", default: "0.0", null: false
    t.decimal "effort_design", default: "0.0", null: false
    t.decimal "effort_management", default: "0.0", null: false
    t.index ["class_of_service"], name: "index_demands_on_class_of_service"
    t.index ["company_id"], name: "index_demands_on_company_id"
    t.index ["contract_id"], name: "index_demands_on_contract_id"
    t.index ["current_stage_id"], name: "index_demands_on_current_stage_id"
    t.index ["customer_id"], name: "index_demands_on_customer_id"
    t.index ["demand_type"], name: "index_demands_on_demand_type"
    t.index ["discarded_at"], name: "index_demands_on_discarded_at"
    t.index ["external_id", "company_id"], name: "index_demands_on_external_id_and_company_id", unique: true
    t.index ["portfolio_unit_id"], name: "index_demands_on_portfolio_unit_id"
    t.index ["product_id"], name: "index_demands_on_product_id"
    t.index ["project_id"], name: "index_demands_on_project_id"
    t.index ["risk_review_id"], name: "index_demands_on_risk_review_id"
    t.index ["service_delivery_review_id"], name: "index_demands_on_service_delivery_review_id"
    t.index ["slug"], name: "index_demands_on_slug", unique: true
    t.index ["team_id"], name: "index_demands_on_team_id"
  end

  create_table "devise_customers", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_devise_customers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_devise_customers_on_reset_password_token", unique: true
  end

  create_table "financial_informations", force: :cascade do |t|
    t.integer "company_id", null: false
    t.date "finances_date", null: false
    t.decimal "income_total", null: false
    t.decimal "expenses_total", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_financial_informations_on_company_id"
  end

  create_table "flow_events", force: :cascade do |t|
    t.integer "project_id"
    t.integer "event_type", null: false
    t.string "event_description", null: false
    t.datetime "event_date", precision: nil, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "risk_review_id"
    t.datetime "discarded_at", precision: nil
    t.integer "event_size", default: 0, null: false
    t.integer "user_id"
    t.date "event_end_date"
    t.integer "company_id", null: false
    t.integer "team_id"
    t.index ["discarded_at"], name: "index_flow_events_on_discarded_at"
    t.index ["event_size"], name: "index_flow_events_on_event_size"
    t.index ["event_type"], name: "index_flow_events_on_event_type"
    t.index ["project_id"], name: "index_flow_events_on_project_id"
    t.index ["risk_review_id"], name: "index_flow_events_on_risk_review_id"
    t.index ["user_id"], name: "index_flow_events_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "initiative_consolidations", force: :cascade do |t|
    t.integer "initiative_id", null: false
    t.date "consolidation_date", null: false
    t.boolean "last_data_in_week", default: false
    t.boolean "last_data_in_month", default: false
    t.boolean "last_data_in_year", default: false
    t.integer "tasks_delivered"
    t.integer "tasks_delivered_in_month"
    t.integer "tasks_delivered_in_week"
    t.decimal "tasks_operational_risk"
    t.integer "tasks_scope"
    t.decimal "tasks_completion_time_p80"
    t.decimal "tasks_completion_time_p80_in_month"
    t.decimal "tasks_completion_time_p80_in_week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consolidation_date"], name: "index_initiative_consolidations_on_consolidation_date"
    t.index ["initiative_id", "consolidation_date"], name: "initiative_consolidation_unique", unique: true
    t.index ["initiative_id"], name: "index_initiative_consolidations_on_initiative_id"
  end

  create_table "initiatives", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "name"], name: "index_initiatives_on_company_id_and_name", unique: true
    t.index ["company_id"], name: "index_initiatives_on_company_id"
    t.index ["name"], name: "index_initiatives_on_name"
  end

  create_table "integration_errors", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "occured_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "integration_type", null: false
    t.string "integration_error_text", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "project_id"
    t.string "integratable_model_name"
    t.index ["company_id"], name: "index_integration_errors_on_company_id"
    t.index ["integratable_model_name"], name: "index_integration_errors_on_integratable_model_name"
    t.index ["integration_type"], name: "index_integration_errors_on_integration_type"
    t.index ["project_id"], name: "index_integration_errors_on_project_id"
  end

  create_table "item_assignments", force: :cascade do |t|
    t.integer "demand_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "start_time", precision: nil, null: false
    t.datetime "finish_time", precision: nil
    t.datetime "discarded_at", precision: nil
    t.decimal "item_assignment_effort", default: "0.0", null: false
    t.boolean "assignment_for_role", default: false
    t.integer "membership_id", null: false
    t.decimal "pull_interval", default: "0.0"
    t.boolean "assignment_notified", default: false, null: false
    t.integer "lock_version"
    t.index ["demand_id"], name: "index_item_assignments_on_demand_id"
    t.index ["discarded_at"], name: "index_item_assignments_on_discarded_at"
    t.index ["membership_id"], name: "index_item_assignments_on_membership_id"
  end

  create_table "jira_accounts", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "username", null: false
    t.string "encrypted_api_token", null: false
    t.string "base_uri", null: false
    t.string "customer_domain", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["base_uri"], name: "index_jira_accounts_on_base_uri", unique: true
    t.index ["company_id"], name: "index_jira_accounts_on_company_id"
    t.index ["customer_domain"], name: "index_jira_accounts_on_customer_domain", unique: true
  end

  create_table "jira_api_errors", force: :cascade do |t|
    t.integer "demand_id", null: false
    t.boolean "processed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["demand_id"], name: "index_jira_api_errors_on_demand_id"
  end

  create_table "jira_custom_field_mappings", force: :cascade do |t|
    t.integer "jira_account_id", null: false
    t.integer "custom_field_type", null: false
    t.string "custom_field_machine_name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["jira_account_id", "custom_field_type"], name: "unique_custom_field_to_jira_account", unique: true
    t.index ["jira_account_id"], name: "index_jira_custom_field_mappings_on_jira_account_id"
  end

  create_table "jira_portfolio_unit_configs", force: :cascade do |t|
    t.integer "portfolio_unit_id", null: false
    t.string "jira_field_name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["portfolio_unit_id"], name: "index_jira_portfolio_unit_configs_on_portfolio_unit_id"
  end

  create_table "jira_product_configs", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "product_id", null: false
    t.string "jira_product_key", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["company_id", "jira_product_key"], name: "index_jira_product_configs_on_company_id_and_jira_product_key", unique: true
    t.index ["company_id"], name: "index_jira_product_configs_on_company_id"
    t.index ["product_id"], name: "index_jira_product_configs_on_product_id"
  end

  create_table "jira_project_configs", force: :cascade do |t|
    t.integer "project_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "fix_version_name", null: false
    t.integer "jira_product_config_id", null: false
    t.index ["fix_version_name"], name: "index_jira_project_configs_on_fix_version_name"
    t.index ["jira_product_config_id", "fix_version_name"], name: "unique_fix_version_to_jira_product", unique: true
    t.index ["jira_product_config_id"], name: "index_jira_project_configs_on_jira_product_config_id"
    t.index ["project_id"], name: "index_jira_project_configs_on_project_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "team_member_id", null: false
    t.integer "team_id", null: false
    t.integer "member_role", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "hours_per_month"
    t.date "start_date", null: false
    t.date "end_date"
    t.index ["team_id"], name: "index_memberships_on_team_id"
    t.index ["team_member_id"], name: "index_memberships_on_team_member_id"
  end

  create_table "operations_dashboard_pairings", force: :cascade do |t|
    t.integer "operations_dashboard_id", null: false
    t.integer "pair_id", null: false
    t.integer "pair_times", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["operations_dashboard_id", "pair_id"], name: "operations_dashboard_pairings_cache_unique", unique: true
    t.index ["operations_dashboard_id"], name: "index_operations_dashboard_pairings_on_operations_dashboard_id"
    t.index ["pair_id"], name: "index_operations_dashboard_pairings_on_pair_id"
  end

  create_table "operations_dashboards", force: :cascade do |t|
    t.date "dashboard_date", null: false
    t.boolean "last_data_in_week", default: false, null: false
    t.boolean "last_data_in_month", default: false, null: false
    t.boolean "last_data_in_year", default: false, null: false
    t.integer "team_member_id", null: false
    t.integer "demands_ids", array: true
    t.integer "first_delivery_id"
    t.integer "delivered_demands_count", default: 0, null: false
    t.integer "bugs_count", default: 0, null: false
    t.decimal "lead_time_min", default: "0.0", null: false
    t.decimal "lead_time_max", default: "0.0", null: false
    t.decimal "lead_time_p80", default: "0.0", null: false
    t.integer "projects_count", default: 0, null: false
    t.decimal "member_effort"
    t.integer "pull_interval"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_member_id", "dashboard_date"], name: "operations_dashboard_cache_unique", unique: true
    t.index ["team_member_id"], name: "index_operations_dashboards_on_team_member_id"
  end

  create_table "plans", force: :cascade do |t|
    t.integer "plan_value", null: false
    t.integer "plan_type", null: false
    t.integer "plan_period", null: false
    t.string "plan_details", null: false
    t.integer "max_number_of_downloads", null: false
    t.integer "max_number_of_users", null: false
    t.integer "max_days_in_history", null: false
    t.decimal "extra_download_value", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "portfolio_units", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "parent_id"
    t.string "name", null: false
    t.integer "portfolio_unit_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name", "product_id"], name: "index_portfolio_units_on_name_and_product_id", unique: true
    t.index ["name"], name: "index_portfolio_units_on_name"
    t.index ["parent_id"], name: "index_portfolio_units_on_parent_id"
    t.index ["portfolio_unit_type"], name: "index_portfolio_units_on_portfolio_unit_type"
    t.index ["product_id"], name: "index_portfolio_units_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "customer_id"
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "company_id", null: false
    t.index ["company_id"], name: "index_products_on_company_id"
    t.index ["customer_id", "name"], name: "index_products_on_customer_id_and_name", unique: true
    t.index ["customer_id"], name: "index_products_on_customer_id"
  end

  create_table "products_projects", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["product_id", "project_id"], name: "index_products_projects_on_product_id_and_project_id", unique: true
    t.index ["product_id"], name: "index_products_projects_on_product_id"
    t.index ["project_id"], name: "index_products_projects_on_project_id"
  end

  create_table "project_broken_wip_logs", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "project_wip", null: false
    t.integer "demands_ids", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_broken_wip_logs_on_project_id"
  end

  create_table "project_change_deadline_histories", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.date "previous_date"
    t.date "new_date"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["project_id"], name: "index_project_change_deadline_histories_on_project_id"
    t.index ["user_id"], name: "index_project_change_deadline_histories_on_user_id"
  end

  create_table "project_consolidations", force: :cascade do |t|
    t.date "consolidation_date", null: false
    t.integer "project_id", null: false
    t.integer "demands_ids", array: true
    t.integer "demands_finished_ids", array: true
    t.integer "wip_limit"
    t.integer "current_wip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "last_data_in_week", default: false, null: false
    t.boolean "last_data_in_month", default: false, null: false
    t.boolean "last_data_in_year", default: false, null: false
    t.integer "project_scope", default: 0
    t.decimal "flow_pressure", default: "0.0"
    t.decimal "project_quality", default: "0.0"
    t.decimal "value_per_demand", default: "0.0"
    t.integer "monte_carlo_weeks_min", default: 0
    t.integer "monte_carlo_weeks_max", default: 0
    t.decimal "monte_carlo_weeks_std_dev", default: "0.0"
    t.decimal "monte_carlo_weeks_p80", default: "0.0"
    t.decimal "operational_risk", default: "0.0"
    t.integer "team_based_monte_carlo_weeks_min", default: 0
    t.integer "team_based_monte_carlo_weeks_max", default: 0
    t.decimal "team_based_monte_carlo_weeks_std_dev", default: "0.0"
    t.decimal "team_based_monte_carlo_weeks_p80", default: "0.0"
    t.decimal "team_based_operational_risk", default: "0.0"
    t.decimal "lead_time_min", default: "0.0"
    t.decimal "lead_time_max", default: "0.0"
    t.decimal "lead_time_p25", default: "0.0"
    t.decimal "lead_time_p75", default: "0.0"
    t.decimal "lead_time_p80", default: "0.0"
    t.decimal "lead_time_average", default: "0.0"
    t.decimal "lead_time_std_dev", default: "0.0"
    t.decimal "lead_time_histogram_bin_min", default: "0.0"
    t.decimal "lead_time_histogram_bin_max", default: "0.0"
    t.decimal "weeks_by_little_law", default: "0.0"
    t.integer "project_throughput", default: 0
    t.decimal "hours_per_demand", default: "0.0"
    t.decimal "flow_efficiency", default: "0.0"
    t.integer "bugs_opened", default: 0
    t.integer "bugs_closed", default: 0
    t.decimal "lead_time_p65", default: "0.0"
    t.decimal "lead_time_p95", default: "0.0"
    t.decimal "lead_time_min_month", default: "0.0"
    t.decimal "lead_time_max_month", default: "0.0"
    t.decimal "lead_time_p80_month", default: "0.0"
    t.decimal "lead_time_std_dev_month", default: "0.0"
    t.decimal "flow_efficiency_month", default: "0.0"
    t.decimal "hours_per_demand_month", default: "0.0"
    t.integer "code_needed_blocks_count", default: 0
    t.decimal "code_needed_blocks_per_demand", default: "0.0"
    t.integer "project_scope_hours", default: 0
    t.decimal "project_throughput_hours", default: "0.0"
    t.decimal "project_throughput_hours_upstream", default: "0.0"
    t.decimal "project_throughput_hours_downstream", default: "0.0"
    t.decimal "project_throughput_hours_in_month"
    t.decimal "project_throughput_hours_upstream_in_month"
    t.decimal "project_throughput_hours_downstream_in_month"
    t.decimal "project_throughput_hours_development", default: "0.0", null: false
    t.decimal "project_throughput_hours_design", default: "0.0", null: false
    t.decimal "project_throughput_hours_management", default: "0.0", null: false
    t.decimal "project_throughput_hours_development_in_month", default: "0.0", null: false
    t.decimal "project_throughput_hours_design_in_month", default: "0.0", null: false
    t.decimal "project_throughput_hours_management_in_month", default: "0.0", null: false
    t.decimal "tasks_based_operational_risk", default: "0.0"
    t.decimal "tasks_based_deadline_p80", default: "0.0"
  end

  create_table "project_risk_alerts", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "project_risk_config_id", null: false
    t.integer "alert_color", null: false
    t.decimal "alert_value", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["project_id"], name: "index_project_risk_alerts_on_project_id"
    t.index ["project_risk_config_id"], name: "index_project_risk_alerts_on_project_risk_config_id"
  end

  create_table "project_risk_configs", force: :cascade do |t|
    t.integer "risk_type", null: false
    t.decimal "high_yellow_value", null: false
    t.decimal "low_yellow_value", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "project_id", null: false
    t.boolean "active", default: true
    t.index ["project_id"], name: "index_project_risk_configs_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.integer "status", null: false
    t.integer "project_type", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.decimal "value"
    t.decimal "qty_hours"
    t.decimal "hour_value"
    t.integer "initial_scope", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "nickname"
    t.integer "percentage_effort_to_bugs", default: 0, null: false
    t.integer "team_id", null: false
    t.decimal "max_work_in_progress", default: "1.0", null: false
    t.integer "company_id", null: false
    t.integer "initiative_id"
    t.index ["company_id", "name"], name: "index_projects_on_company_id_and_name", unique: true
    t.index ["company_id"], name: "index_projects_on_company_id"
    t.index ["team_id"], name: "index_projects_on_team_id"
  end

  create_table "replenishing_consolidations", force: :cascade do |t|
    t.integer "project_id", null: false
    t.date "consolidation_date", null: false
    t.decimal "project_based_risks_to_deadline"
    t.decimal "flow_pressure"
    t.decimal "relative_flow_pressure"
    t.decimal "qty_using_pressure"
    t.decimal "leadtime_80"
    t.decimal "qty_selected_last_week"
    t.decimal "work_in_progress"
    t.decimal "montecarlo_80_percent"
    t.decimal "customer_happiness"
    t.integer "max_work_in_progress"
    t.integer "project_throughput_data", array: true
    t.integer "team_wip"
    t.integer "team_throughput_data", array: true
    t.decimal "team_lead_time"
    t.decimal "team_based_montecarlo_80_percent"
    t.decimal "team_monte_carlo_weeks_std_dev"
    t.decimal "team_monte_carlo_weeks_min"
    t.decimal "team_monte_carlo_weeks_max"
    t.decimal "team_based_odds_to_deadline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consolidation_date"], name: "index_replenishing_consolidations_on_consolidation_date"
    t.index ["project_id", "consolidation_date"], name: "idx_replenishing_unique", unique: true
    t.index ["project_id"], name: "index_replenishing_consolidations_on_project_id"
  end

  create_table "risk_review_action_items", force: :cascade do |t|
    t.integer "risk_review_id", null: false
    t.integer "membership_id", null: false
    t.date "created_date", null: false
    t.integer "action_type", default: 0, null: false
    t.string "description", null: false
    t.date "deadline", null: false
    t.date "done_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_risk_review_action_items_on_action_type"
    t.index ["membership_id"], name: "index_risk_review_action_items_on_membership_id"
    t.index ["risk_review_id"], name: "index_risk_review_action_items_on_risk_review_id"
  end

  create_table "risk_reviews", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "product_id", null: false
    t.date "meeting_date", null: false
    t.decimal "lead_time_outlier_limit", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "weekly_avg_blocked_time", array: true
    t.decimal "monthly_avg_blocked_time", array: true
    t.index ["company_id"], name: "index_risk_reviews_on_company_id"
    t.index ["meeting_date", "product_id"], name: "index_risk_reviews_on_meeting_date_and_product_id", unique: true
    t.index ["product_id"], name: "index_risk_reviews_on_product_id"
  end

  create_table "score_matrices", force: :cascade do |t|
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_score_matrices_on_product_id"
  end

  create_table "score_matrix_answers", force: :cascade do |t|
    t.integer "score_matrix_question_id", null: false
    t.string "description", null: false
    t.integer "answer_value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_value", "score_matrix_question_id"], name: "idx_demand_score_answers_unique", unique: true
    t.index ["score_matrix_question_id"], name: "index_score_matrix_answers_on_score_matrix_question_id"
  end

  create_table "score_matrix_questions", force: :cascade do |t|
    t.integer "score_matrix_id", null: false
    t.integer "question_type", default: 0, null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "question_weight", null: false
    t.index ["score_matrix_id"], name: "index_score_matrix_questions_on_score_matrix_id"
  end

  create_table "service_delivery_reviews", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "product_id", null: false
    t.date "meeting_date", null: false
    t.decimal "lead_time_top_threshold", null: false
    t.decimal "lead_time_bottom_threshold", null: false
    t.decimal "quality_top_threshold", null: false
    t.decimal "quality_bottom_threshold", null: false
    t.integer "expedite_max_pull_time_sla", null: false
    t.decimal "delayed_expedite_top_threshold", null: false
    t.decimal "delayed_expedite_bottom_threshold", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bugs_ids", array: true
    t.index ["company_id"], name: "index_service_delivery_reviews_on_company_id"
    t.index ["meeting_date", "product_id"], name: "index_service_delivery_reviews_on_meeting_date_and_product_id", unique: true
    t.index ["product_id"], name: "index_service_delivery_reviews_on_product_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "slack_configurations", force: :cascade do |t|
    t.integer "team_id", null: false
    t.string "room_webhook", null: false
    t.integer "notification_hour"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "info_type", default: 0, null: false
    t.integer "weekday_to_notify", default: 0, null: false
    t.integer "notification_minute"
    t.boolean "active", default: true
    t.integer "stages_to_notify_transition", array: true
    t.index ["info_type", "team_id"], name: "index_slack_configurations_on_info_type_and_team_id", unique: true
    t.index ["info_type"], name: "index_slack_configurations_on_info_type"
    t.index ["team_id"], name: "index_slack_configurations_on_team_id"
  end

  create_table "stage_project_configs", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "stage_id", null: false
    t.boolean "compute_effort", default: false
    t.integer "stage_percentage", default: 0, null: false
    t.integer "management_percentage", default: 0, null: false
    t.integer "pairing_percentage", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "max_seconds_in_stage", default: 0
    t.index ["project_id", "stage_id"], name: "index_stage_project_configs_on_project_id_and_stage_id", unique: true
    t.index ["project_id"], name: "index_stage_project_configs_on_project_id"
    t.index ["stage_id"], name: "index_stage_project_configs_on_stage_id"
  end

  create_table "stages", force: :cascade do |t|
    t.string "integration_id", null: false
    t.string "name", null: false
    t.integer "stage_type", default: 0, null: false
    t.integer "stage_stream", default: 0, null: false
    t.boolean "commitment_point", default: false
    t.boolean "end_point", default: false
    t.boolean "queue", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "company_id", null: false
    t.integer "order", default: 0, null: false
    t.string "integration_pipe_id"
    t.index ["company_id"], name: "index_stages_on_company_id"
    t.index ["integration_id"], name: "index_stages_on_integration_id"
    t.index ["name"], name: "index_stages_on_name"
  end

  create_table "stages_teams", force: :cascade do |t|
    t.integer "stage_id", null: false
    t.integer "team_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["stage_id", "team_id"], name: "index_stages_teams_on_stage_id_and_team_id", unique: true
    t.index ["stage_id"], name: "index_stages_teams_on_stage_id"
    t.index ["team_id"], name: "index_stages_teams_on_team_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "demand_id", null: false
    t.datetime "created_date", precision: nil, null: false
    t.string "title", null: false
    t.integer "external_id"
    t.integer "seconds_to_complete"
    t.datetime "end_date", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at", precision: nil
    t.index ["demand_id"], name: "index_tasks_on_demand_id"
    t.index ["discarded_at"], name: "index_tasks_on_discarded_at"
  end

  create_table "team_consolidations", force: :cascade do |t|
    t.integer "team_id", null: false
    t.date "consolidation_date", null: false
    t.boolean "last_data_in_week", default: false
    t.boolean "last_data_in_month", default: false
    t.boolean "last_data_in_year", default: false
    t.decimal "consumed_hours_in_month", default: "0.0"
    t.decimal "lead_time_p80", default: "0.0"
    t.decimal "lead_time_p80_in_week", default: "0.0"
    t.decimal "lead_time_p80_in_month", default: "0.0"
    t.decimal "lead_time_p80_in_quarter", default: "0.0"
    t.decimal "lead_time_p80_in_semester", default: "0.0"
    t.decimal "lead_time_p80_in_year", default: "0.0"
    t.decimal "flow_efficiency", default: "0.0"
    t.decimal "flow_efficiency_in_month", default: "0.0"
    t.decimal "flow_efficiency_in_quarter", default: "0.0"
    t.decimal "flow_efficiency_in_semester", default: "0.0"
    t.decimal "flow_efficiency_in_year", default: "0.0"
    t.decimal "hours_per_demand", default: "0.0"
    t.decimal "hours_per_demand_in_month", default: "0.0"
    t.decimal "hours_per_demand_in_quarter", default: "0.0"
    t.decimal "hours_per_demand_in_semester", default: "0.0"
    t.decimal "hours_per_demand_in_year", default: "0.0"
    t.decimal "value_per_demand", default: "0.0"
    t.decimal "value_per_demand_in_month", default: "0.0"
    t.decimal "value_per_demand_in_quarter", default: "0.0"
    t.decimal "value_per_demand_in_semester", default: "0.0"
    t.decimal "value_per_demand_in_year", default: "0.0"
    t.integer "qty_demands_created", default: 0
    t.integer "qty_demands_created_in_week", default: 0
    t.integer "qty_demands_committed", default: 0
    t.integer "qty_demands_committed_in_week", default: 0
    t.integer "qty_demands_finished_upstream", default: 0
    t.integer "qty_demands_finished_upstream_in_week", default: 0
    t.integer "qty_demands_finished_upstream_in_month", default: 0
    t.integer "qty_demands_finished_upstream_in_quarter", default: 0
    t.integer "qty_demands_finished_upstream_in_semester", default: 0
    t.integer "qty_demands_finished_upstream_in_year", default: 0
    t.integer "qty_demands_finished_downstream", default: 0
    t.integer "qty_demands_finished_downstream_in_week", default: 0
    t.integer "qty_demands_finished_downstream_in_month", default: 0
    t.integer "qty_demands_finished_downstream_in_quarter", default: 0
    t.integer "qty_demands_finished_downstream_in_semester", default: 0
    t.integer "qty_demands_finished_downstream_in_year", default: 0
    t.integer "qty_bugs_opened", default: 0
    t.integer "qty_bugs_opened_in_month", default: 0
    t.integer "qty_bugs_opened_in_quarter", default: 0
    t.integer "qty_bugs_opened_in_semester", default: 0
    t.integer "qty_bugs_opened_in_year", default: 0
    t.integer "qty_bugs_closed", default: 0
    t.integer "qty_bugs_closed_in_month", default: 0
    t.integer "qty_bugs_closed_in_quarter", default: 0
    t.integer "qty_bugs_closed_in_semester", default: 0
    t.integer "qty_bugs_closed_in_year", default: 0
    t.decimal "bugs_share", default: "0.0"
    t.decimal "bugs_share_in_month", default: "0.0"
    t.decimal "bugs_share_in_quarter", default: "0.0"
    t.decimal "bugs_share_in_semester", default: "0.0"
    t.decimal "bugs_share_in_year", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "development_consumed_hours", default: "0.0", null: false
    t.decimal "design_consumed_hours", default: "0.0", null: false
    t.decimal "management_consumed_hours", default: "0.0", null: false
    t.decimal "development_consumed_hours_in_month", default: "0.0", null: false
    t.decimal "design_consumed_hours_in_month", default: "0.0", null: false
    t.decimal "management_consumed_hours_in_month", default: "0.0", null: false
    t.index ["last_data_in_month"], name: "index_team_consolidations_on_last_data_in_month"
    t.index ["last_data_in_week"], name: "index_team_consolidations_on_last_data_in_week"
    t.index ["last_data_in_year"], name: "index_team_consolidations_on_last_data_in_year"
    t.index ["team_id", "consolidation_date"], name: "team_consolidation_unique", unique: true
    t.index ["team_id"], name: "index_team_consolidations_on_team_id"
  end

  create_table "team_members", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "monthly_payment"
    t.boolean "billable", default: true
    t.integer "billable_type", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "start_date"
    t.date "end_date"
    t.string "jira_account_user_email"
    t.string "jira_account_id"
    t.integer "company_id", null: false
    t.integer "user_id"
    t.integer "hours_per_month", default: 0
    t.index ["company_id", "name", "jira_account_id"], name: "index_team_members_on_company_id_and_name_and_jira_account_id", unique: true
    t.index ["company_id"], name: "index_team_members_on_company_id"
    t.index ["jira_account_id"], name: "index_team_members_on_jira_account_id"
    t.index ["jira_account_user_email"], name: "index_team_members_on_jira_account_user_email"
    t.index ["user_id"], name: "index_team_members_on_user_id"
  end

  create_table "team_resource_allocations", force: :cascade do |t|
    t.integer "team_resource_id", null: false
    t.integer "team_id", null: false
    t.decimal "monthly_payment", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_resource_allocations_on_team_id"
    t.index ["team_resource_id"], name: "index_team_resource_allocations_on_team_resource_id"
  end

  create_table "team_resources", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "resource_type", null: false
    t.string "resource_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_team_resources_on_company_id"
    t.index ["resource_name"], name: "index_team_resources_on_resource_name"
    t.index ["resource_type"], name: "index_team_resources_on_resource_type"
  end

  create_table "teams", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "max_work_in_progress", default: 0, null: false
    t.index ["company_id", "name"], name: "index_teams_on_company_id_and_name", unique: true
    t.index ["company_id"], name: "index_teams_on_company_id"
  end

  create_table "user_company_roles", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_role", default: 0, null: false
    t.date "start_date"
    t.date "end_date"
    t.string "slack_user"
    t.index ["company_id"], name: "index_user_company_roles_on_company_id"
    t.index ["id"], name: "index_user_company_roles_on_id"
    t.index ["user_id", "company_id"], name: "index_user_company_roles_on_user_id_and_company_id", unique: true
    t.index ["user_id"], name: "index_user_company_roles_on_user_id"
    t.index ["user_role"], name: "index_user_company_roles_on_user_role"
  end

  create_table "user_invites", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "invite_status", null: false
    t.integer "invite_type", null: false
    t.integer "invite_object_id", null: false
    t.string "invite_email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_user_invites_on_company_id"
    t.index ["invite_email"], name: "index_user_invites_on_invite_email"
    t.index ["invite_object_id"], name: "index_user_invites_on_invite_object_id"
    t.index ["invite_status"], name: "index_user_invites_on_invite_status"
    t.index ["invite_type"], name: "index_user_invites_on_invite_type"
  end

  create_table "user_plans", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "plan_id", null: false
    t.integer "plan_billing_period", default: 0, null: false
    t.decimal "plan_value", default: "0.0", null: false
    t.datetime "start_at", precision: nil, null: false
    t.datetime "finish_at", precision: nil, null: false
    t.boolean "active", default: false, null: false
    t.boolean "paid", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["plan_id"], name: "index_user_plans_on_plan_id"
    t.index ["user_id"], name: "index_user_plans_on_user_id"
  end

  create_table "user_project_roles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.integer "role_in_project", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["project_id"], name: "index_user_project_roles_on_project_id"
    t.index ["user_id", "project_id"], name: "index_user_project_roles_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_user_project_roles_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.integer "last_company_id"
    t.boolean "email_notifications", default: false, null: false
    t.decimal "user_money_credits", default: "0.0", null: false
    t.string "avatar"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "azure_custom_fields", "azure_accounts"
  add_foreign_key "azure_projects", "azure_teams"
  add_foreign_key "azure_teams", "azure_product_configs"
  add_foreign_key "class_of_service_change_histories", "demands"
  add_foreign_key "company_settings", "companies"
  add_foreign_key "contract_consolidations", "contracts"
  add_foreign_key "contract_estimation_change_histories", "contracts"
  add_foreign_key "contracts", "contracts"
  add_foreign_key "contracts", "customers"
  add_foreign_key "contracts", "products"
  add_foreign_key "customer_consolidations", "customers"
  add_foreign_key "customers", "companies"
  add_foreign_key "customers", "customers"
  add_foreign_key "customers_devise_customers", "customers"
  add_foreign_key "customers_devise_customers", "devise_customers"
  add_foreign_key "customers_projects", "customers"
  add_foreign_key "customers_projects", "projects"
  add_foreign_key "demand_block_notifications", "demand_blocks"
  add_foreign_key "demand_blocks", "demands"
  add_foreign_key "demand_blocks", "risk_reviews"
  add_foreign_key "demand_blocks", "stages"
  add_foreign_key "demand_blocks", "team_members", column: "blocker_id"
  add_foreign_key "demand_blocks", "team_members", column: "unblocker_id"
  add_foreign_key "demand_comments", "demands"
  add_foreign_key "demand_comments", "team_members"
  add_foreign_key "demand_efforts", "demand_transitions"
  add_foreign_key "demand_efforts", "demands"
  add_foreign_key "demand_efforts", "item_assignments"
  add_foreign_key "demand_score_matrices", "demands"
  add_foreign_key "demand_score_matrices", "score_matrix_answers"
  add_foreign_key "demand_score_matrices", "users"
  add_foreign_key "demand_transitions", "demands"
  add_foreign_key "demand_transitions", "stages"
  add_foreign_key "demand_transitions", "team_members"
  add_foreign_key "demands", "contracts"
  add_foreign_key "demands", "customers"
  add_foreign_key "demands", "portfolio_units"
  add_foreign_key "demands", "products"
  add_foreign_key "demands", "projects"
  add_foreign_key "demands", "risk_reviews"
  add_foreign_key "demands", "service_delivery_reviews"
  add_foreign_key "demands", "stages", column: "current_stage_id"
  add_foreign_key "demands", "teams"
  add_foreign_key "financial_informations", "companies"
  add_foreign_key "flow_events", "projects"
  add_foreign_key "flow_events", "risk_reviews"
  add_foreign_key "flow_events", "users"
  add_foreign_key "initiative_consolidations", "initiatives"
  add_foreign_key "initiatives", "companies"
  add_foreign_key "integration_errors", "companies"
  add_foreign_key "integration_errors", "projects"
  add_foreign_key "item_assignments", "demands"
  add_foreign_key "item_assignments", "memberships"
  add_foreign_key "jira_accounts", "companies"
  add_foreign_key "jira_api_errors", "demands"
  add_foreign_key "jira_custom_field_mappings", "jira_accounts"
  add_foreign_key "jira_portfolio_unit_configs", "portfolio_units"
  add_foreign_key "jira_product_configs", "companies"
  add_foreign_key "jira_product_configs", "products"
  add_foreign_key "jira_project_configs", "jira_product_configs"
  add_foreign_key "jira_project_configs", "projects"
  add_foreign_key "memberships", "team_members"
  add_foreign_key "memberships", "teams"
  add_foreign_key "operations_dashboard_pairings", "operations_dashboards"
  add_foreign_key "operations_dashboard_pairings", "team_members", column: "pair_id"
  add_foreign_key "operations_dashboards", "demands", column: "first_delivery_id"
  add_foreign_key "operations_dashboards", "team_members"
  add_foreign_key "portfolio_units", "portfolio_units", column: "parent_id"
  add_foreign_key "portfolio_units", "products"
  add_foreign_key "products", "companies"
  add_foreign_key "products", "customers"
  add_foreign_key "products_projects", "products"
  add_foreign_key "products_projects", "projects"
  add_foreign_key "project_broken_wip_logs", "projects"
  add_foreign_key "project_change_deadline_histories", "projects"
  add_foreign_key "project_change_deadline_histories", "users"
  add_foreign_key "project_consolidations", "projects"
  add_foreign_key "project_risk_alerts", "project_risk_configs"
  add_foreign_key "project_risk_alerts", "projects"
  add_foreign_key "projects", "companies"
  add_foreign_key "projects", "initiatives"
  add_foreign_key "projects", "teams"
  add_foreign_key "replenishing_consolidations", "projects"
  add_foreign_key "risk_review_action_items", "memberships"
  add_foreign_key "risk_review_action_items", "risk_reviews"
  add_foreign_key "risk_reviews", "companies"
  add_foreign_key "risk_reviews", "products"
  add_foreign_key "score_matrices", "products"
  add_foreign_key "score_matrix_answers", "score_matrix_questions"
  add_foreign_key "score_matrix_questions", "score_matrices"
  add_foreign_key "service_delivery_reviews", "companies"
  add_foreign_key "service_delivery_reviews", "products"
  add_foreign_key "slack_configurations", "teams"
  add_foreign_key "stage_project_configs", "projects"
  add_foreign_key "stage_project_configs", "stages"
  add_foreign_key "stages", "companies"
  add_foreign_key "stages_teams", "stages"
  add_foreign_key "stages_teams", "teams"
  add_foreign_key "tasks", "demands"
  add_foreign_key "team_consolidations", "teams"
  add_foreign_key "team_members", "companies"
  add_foreign_key "team_members", "users"
  add_foreign_key "team_resource_allocations", "team_resources"
  add_foreign_key "team_resource_allocations", "teams"
  add_foreign_key "team_resources", "companies"
  add_foreign_key "teams", "companies"
  add_foreign_key "user_company_roles", "companies"
  add_foreign_key "user_company_roles", "users"
  add_foreign_key "user_invites", "companies"
  add_foreign_key "user_plans", "plans"
  add_foreign_key "user_plans", "users"
  add_foreign_key "user_project_roles", "projects"
  add_foreign_key "user_project_roles", "users"
  add_foreign_key "users", "companies", column: "last_company_id"
end
