module SpaHelper
  def spa_controllers
    [
      { controller: 'replenishing_consolidations', action: 'index' },
      { controller: 'projects', action: 'index' },
      { controller: 'projects', action: 'show' },
      { controller: 'projects', action: 'status_report_dashboard' },
      { controller: 'projects', action: 'risk_drill_down' },
      { controller: 'projects', action: 'lead_time_dashboard' },
      { controller: 'projects', action: 'statistics_tab' },
      { controller: 'projects', action: 'financial_report' },
      { controller: 'products', action: 'show' },
      { controller: 'products', action: 'risk_reviews_tab' },
      { controller: 'products', action: 'service_delivery_reviews_tab' },
      { controller: 'products', action: 'bvp' },
      { controller: 'risk_reviews', action: 'new' },
      { controller: 'risk_reviews', action: 'show' },
      { controller: 'service_delivery_reviews', action: 'show' },
      { controller: 'project_additional_hours', action: 'new' },
      { controller: 'teams', action: 'show' },
      { controller: 'teams', action: 'index' },
      { controller: 'teams', action: 'new' },
      { controller: 'teams', action: 'edit' },
      { controller: 'team_members', action: 'index' },
      { controller: 'team_members', action: 'edit' },
      { controller: 'team_members', action: 'show' },
      { controller: 'demands', action: 'index' },
      { controller: 'demands', action: 'demands_charts' },
      { controller: 'demands', action: 'demand_efforts' },
      { controller: 'demand_efforts', action: 'new' },
      { controller: 'work_item_types', action: 'new' },
      { controller: 'work_item_types', action: 'index' },
      { controller: 'devise_customers/customer_demands', action: 'show' },
      { controller: 'devise_customers/customer_demands', action: 'demand_efforts' },
      { controller: 'memberships', action: 'index' },
      { controller: 'memberships', action: 'edit' },
      { controller: 'memberships', action: 'efficiency_table' },
      { controller: 'portfolio_units', action: 'index' },
      { controller: 'portfolio_units', action: 'new' },
      { controller: 'jira/jira_project_configs', action: 'edit' },
      { controller: 'jira/jira_project_configs', action: 'index' },
      { controller: "users", action: "manager_home" },
      { controller: "product_users", action: "index" }
    ]
  end
end
