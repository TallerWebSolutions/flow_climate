# frozen_string_literal: true

# == Schema Information
#
# Table name: replenishing_consolidations
#
#  id                               :integer          not null, primary key
#  project_id                       :integer          not null
#  consolidation_date               :date             not null
#  project_based_risks_to_deadline  :decimal(, )
#  flow_pressure                    :decimal(, )
#  relative_flow_pressure           :decimal(, )
#  qty_using_pressure               :decimal(, )
#  leadtime_80                      :decimal(, )
#  qty_selected_last_week           :decimal(, )
#  work_in_progress                 :decimal(, )
#  montecarlo_80_percent            :decimal(, )
#  customer_happiness               :decimal(, )
#  max_work_in_progress             :integer
#  project_throughput_data          :integer          is an Array
#  team_wip                         :integer
#  team_throughput_data             :integer          is an Array
#  team_lead_time                   :decimal(, )
#  team_based_montecarlo_80_percent :decimal(, )
#  team_monte_carlo_weeks_std_dev   :decimal(, )
#  team_monte_carlo_weeks_min       :decimal(, )
#  team_monte_carlo_weeks_max       :decimal(, )
#  team_based_odds_to_deadline      :decimal(, )
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#
# Indexes
#
#  idx_replenishing_unique                                  (project_id,consolidation_date) UNIQUE
#  index_replenishing_consolidations_on_consolidation_date  (consolidation_date)
#  index_replenishing_consolidations_on_project_id          (project_id)
#

module Consolidations
  class ReplenishingConsolidation < ApplicationRecord
    belongs_to :project

    def average_team_throughput
      return 0 if team_throughput_data.blank?

      team_throughput_data.sum.to_f / team_throughput_data.count
    end

    def project_throughput_data_stddev
      Stats::StatisticsService.instance.standard_deviation(project_throughput_data)
    end

    def project_throughput_data_mode
      Stats::StatisticsService.instance.mode(project_throughput_data)
    end

    def increased_pressure?
      return false if last_consolidation.blank?

      last_consolidation.flow_pressure < flow_pressure
    end

    def increased_leadtime_80?
      return false if last_consolidation.blank?

      last_consolidation.leadtime_80 < leadtime_80
    end

    def increased_work_in_progress?
      return false if last_consolidation.blank?

      last_consolidation.work_in_progress < work_in_progress
    end

    def increased_avg_throughtput?
      return false if last_consolidation.blank?

      last_consolidation.average_team_throughput < average_team_throughput
    end

    def increased_team_lead_time?
      return false if last_consolidation.blank? || last_consolidation.team_lead_time.blank? || team_lead_time.blank?

      last_consolidation.team_lead_time < team_lead_time
    end

    private

    def last_consolidation
      Consolidations::ReplenishingConsolidation.where('consolidation_date < :limit_date', limit_date: consolidation_date).order(:consolidation_date).last
    end
  end
end
