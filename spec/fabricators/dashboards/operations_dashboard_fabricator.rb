# frozen-string-literal: true

Fabricator(:operations_dashboard, from: 'Dashboards::OperationsDashboard') do
  team_member

  dashboard_date { Time.zone.today }
end
