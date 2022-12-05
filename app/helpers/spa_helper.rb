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
      { controller: 'projects', action: 'tasks_tab' },
      { controller: 'products', action: 'show' },
      { controller: 'project_additional_hours', action: 'new' },
      { controller: 'teams', action: 'show' },
      { controller: 'teams', action: 'index' },
      { controller: 'teams', action: 'new' },
      { controller: 'teams', action: 'edit' },
      { controller: 'tasks', action: 'index' },
      { controller: 'tasks', action: 'charts' },
      { controller: 'team_members', action: 'index' },
      { controller: 'team_members', action: 'edit' },
      { controller: 'team_members', action: 'show' },
      { controller: 'initiatives', action: 'index' },
      { controller: 'initiatives', action: 'edit' },
      { controller: 'demands', action: 'index' },
      { controller: 'demands', action: 'demands_charts' },
      { controller: 'work_item_types', action: 'new' },
      { controller: 'work_item_types', action: 'index' }
    ]
  end
end