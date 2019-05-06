# frozen_string_literal: true

Fabricator(:project_consolidation) do
  project
  consolidation_date { Time.zone.today }
  current_wip 10
  customer_happiness 1.2
  demands_finished_ids [1, 2, 3]
  demands_ids [1, 2, 3, 4]
  demands_lead_times [1.2, 3.2, 2.1]
  demands_lead_times_average 1.5
  demands_lead_times_std_dev 0.3
  flow_pressure 2.1
  flow_pressure_percentage 50.2
  histogram_range 10
  interquartile_range 3
  last_lead_time_p80 4.3
  last_throughput_per_week_data [3, 2, 4, 1, 5]
  lead_time_histogram_bin_max 4.3
  lead_time_histogram_bin_min 2.1
  lead_time_max 2.1
  lead_time_min 2.2
  lead_time_p25 3.2
  lead_time_p75 4.4
  population_end_date { 1.day.from_now }
  population_start_date { 1.day.ago }
  project_aging 10
  project_monte_carlo_weeks_p80 5
  team_monte_carlo_weeks_p80 6
  total_range 1.2
  weeks_to_deadline 4
  wip_limit 2
end
