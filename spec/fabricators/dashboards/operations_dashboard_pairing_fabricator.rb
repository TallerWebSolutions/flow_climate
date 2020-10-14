# frozen-string-literal: true

Fabricator(:operations_dashboard_pairing, from: 'Dashboards::OperationsDashboardPairing') do
  operations_dashboard
  pair { Fabricate :team_member }
  pair_times { 4 }
end
