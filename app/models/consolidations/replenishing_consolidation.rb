# frozen-string-literal: true

# == Schema Information
#
# Table name: replenishing_consolidations
#
#  id                               :bigint           not null, primary key
#  consolidation_date               :date             not null
#  customer_happiness               :decimal(, )
#  flow_pressure                    :decimal(, )
#  leadtime_80                      :decimal(, )
#  max_work_in_progress             :integer
#  montecarlo_80_percent            :decimal(, )
#  project_based_risks_to_deadline  :decimal(, )
#  project_throughput_data          :integer          is an Array
#  qty_selected_last_week           :decimal(, )
#  qty_using_pressure               :decimal(, )
#  relative_flow_pressure           :decimal(, )
#  team_based_montecarlo_80_percent :decimal(, )
#  team_based_odds_to_deadline      :decimal(, )
#  team_monte_carlo_weeks_max       :decimal(, )
#  team_monte_carlo_weeks_min       :decimal(, )
#  team_monte_carlo_weeks_std_dev   :decimal(, )
#  throughput_data_stddev           :integer
#  work_in_progress                 :decimal(, )
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  project_id                       :integer          not null
#
# Indexes
#
#  index_replenishing_consolidations_on_consolidation_date  (consolidation_date)
#  index_replenishing_consolidations_on_project_id          (project_id)
#

module Consolidations
  class ReplenishingConsolidation < ApplicationRecord
    belongs_to :project
  end
end
