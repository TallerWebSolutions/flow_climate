# frozen_string_literal: true

module Consolidations
  class ReplenishingConsolidationJob < ApplicationJob
    queue_as :consolidations

    def perform
      Company.all.each do |company|
        company.teams.each do |team|
          replenishing_data = ReplenishingData.new(team)
          replenishing_data.project_data_to_replenish.each do |project_hash|
            consolidation = Consolidations::ReplenishingConsolidation.where(consolidation_date: Time.zone.today, project_id: project_hash[:id]).first_or_initialize

            consolidation.update(
                project_id: project_hash[:id],
                consolidation_date: Time.zone.today,
                customer_happiness: project_hash[:customer_happiness].to_d,
                flow_pressure: project_hash[:flow_pressure].to_d,
                leadtime_80: project_hash[:leadtime_80].to_d,
                max_work_in_progress: project_hash[:max_work_in_progress].to_i,
                montecarlo_80_percent: project_hash[:montecarlo_80_percent].to_d,
                project_based_risks_to_deadline: project_hash[:project_based_risks_to_deadline].to_d,
                project_throughput_data: project_hash[:throughput_data],
                qty_selected_last_week: project_hash[:qty_selected_last_week],
                qty_using_pressure: project_hash[:qty_using_pressure].to_d,
                relative_flow_pressure: project_hash[:relative_flow_pressure].to_d,
                team_wip: replenishing_data.summary_infos[:team_wip],
                team_throughput_data: replenishing_data.summary_infos[:four_last_throughputs],
                team_lead_time: replenishing_data.summary_infos[:team_lead_time],
                team_based_montecarlo_80_percent: project_hash[:team_based_montecarlo_80_percent].to_d,
                team_based_odds_to_deadline: project_hash[:team_based_odds_to_deadline].to_d,
                team_monte_carlo_weeks_max: project_hash[:team_monte_carlo_weeks_max],
                team_monte_carlo_weeks_min: project_hash[:team_monte_carlo_weeks_min],
                team_monte_carlo_weeks_std_dev: project_hash[:team_monte_carlo_weeks_std_dev].to_d,
                work_in_progress: project_hash[:work_in_progress],
            )
          end
        end
      end
    end
  end
end
