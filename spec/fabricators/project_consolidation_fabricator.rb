# frozen_string_literal: true

Fabricator(:project_consolidation) do
  project
  consolidation_date { Time.zone.today }
  demands_finished_ids [1, 2, 5, 7]
  demands_ids [1, 2, 5, 7, 9, 10, 112]
  demands_lead_times [1.2, 4.5, 6.8]
  population_end_date { Time.zone.yesterday }
  population_start_date { 4.days.ago }
  products_monte_carlo_weeks [4, 3, 2, 1]
  products_weekly_throughput [10, 54, 22, 12, 10]
  project_monte_carlo_weeks [1, 2, 3, 5, 6, 7, 7, 7]
  project_weekly_throughput [2, 3, 5]
  team_monte_carlo_weeks [0, 0, 0, 2, 4, 4, 4, 4, 5]
  team_weekly_throughput [0, 0, 0, 10, 12, 11, 18]
  wip_limit 10
end
