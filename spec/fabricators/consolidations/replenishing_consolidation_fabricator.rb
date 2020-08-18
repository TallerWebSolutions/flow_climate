# frozen_string_literal: true

Fabricator(:replenishing_consolidation, from: 'Consolidations::ReplenishingConsolidation') do
  project
  consolidation_date { Time.zone.today }
  customer_happiness { 1.4 }
  flow_pressure { 2.7 }
  leadtime_80 { 10.2 }
  max_work_in_progress { 10.2 }
  montecarlo_80_percent { 15.5 }
  project_based_risks_to_deadline { 0.85 }
  project_throughput_data { [2, 3, 2, 3, 4, 2] }
  qty_selected_last_week { 3 }
  qty_using_pressure { 2.1 }
  relative_flow_pressure { 0.9 }
  team_based_montecarlo_80_percent { 10.1 }
  team_based_odds_to_deadline { 0.92 }
  team_monte_carlo_weeks_max { 20 }
  team_monte_carlo_weeks_min { 4 }
  team_monte_carlo_weeks_std_dev { 1.2 }
  work_in_progress { 2 }
end
