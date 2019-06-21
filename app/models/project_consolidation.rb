# frozen_string_literal: true

# == Schema Information
#
# Table name: project_consolidations
#
#  all_data_little_law_weeks               :decimal(, )      default(0.0)
#  consolidation_date                      :date             not null
#  created_at                              :datetime         not null
#  current_wip                             :integer
#  customer_happiness                      :decimal(, )
#  demands_finished_ids                    :integer          is an Array
#  demands_ids                             :integer          is an Array
#  demands_lead_times                      :decimal(, )      is an Array
#  demands_lead_times_average              :decimal(, )
#  demands_lead_times_std_dev              :decimal(, )
#  flow_pressure                           :decimal(, )
#  flow_pressure_percentage                :decimal(, )
#  histogram_range                         :decimal(, )
#  id                                      :bigint(8)        not null, primary key
#  interquartile_range                     :decimal(, )
#  last_8_data_little_law_weeks            :decimal(, )      default(0.0)
#  last_8_throughput_average               :decimal(, )      default(0.0)
#  last_8_throughput_per_week_data         :integer          is an Array
#  last_8_throughput_std_dev               :decimal(, )      default(0.0)
#  last_lead_time_p80                      :decimal(, )
#  lead_time_histogram_bin_max             :decimal(, )
#  lead_time_histogram_bin_min             :decimal(, )
#  lead_time_max                           :decimal(, )
#  lead_time_min                           :decimal(, )
#  lead_time_p25                           :decimal(, )
#  lead_time_p75                           :decimal(, )
#  max_weeks_montecarlo_project            :integer
#  max_weeks_montecarlo_team               :integer
#  min_weeks_montecarlo_project            :integer
#  min_weeks_montecarlo_project_percentage :decimal(, )      default(0.0)
#  min_weeks_montecarlo_team               :integer
#  min_weeks_montecarlo_team_percentage    :decimal(, )      default(0.0)
#  odds_to_deadline_project                :float
#  odds_to_deadline_team                   :float
#  population_end_date                     :date
#  population_start_date                   :date
#  project_aging                           :integer          default(0), not null
#  project_id                              :integer          not null
#  project_monte_carlo_weeks_p80           :decimal(, )
#  remaining_scope                         :integer          default(0)
#  std_dev_weeks_montecarlo_project        :float
#  std_dev_weeks_montecarlo_team           :float
#  team_monte_carlo_weeks_p80              :decimal(, )
#  throughput_average                      :decimal(, )      default(0.0)
#  throughput_per_week_data                :integer          is an Array
#  throughput_std_dev                      :decimal(, )      default(0.0)
#  total_range                             :decimal(, )
#  updated_at                              :datetime         not null
#  weeks_to_deadline                       :integer          default(0), not null
#  wip_limit                               :integer
#
# Foreign Keys
#
#  fk_rails_09ca62cd76  (project_id => projects.id)
#

class ProjectConsolidation < ApplicationRecord
  belongs_to :project

  validates :project, :project_aging, :consolidation_date, presence: true
end
