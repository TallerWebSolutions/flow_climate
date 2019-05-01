# frozen_string_literal: true

# == Schema Information
#
# Table name: flow_consolidations
#
#  average_customer_happiness    :decimal(, )      not null
#  consolidation_date            :date             not null
#  created_at                    :datetime         not null
#  current_wip                   :integer          not null
#  demands_ids                   :integer          not null, is an Array
#  demands_lead_times            :decimal(, )      not null, is an Array
#  demands_lead_times_average    :decimal(, )      not null
#  demands_lead_times_std_dev    :decimal(, )      not null
#  flow_pressure                 :decimal(, )      not null
#  flow_total_cost               :decimal(, )      not null
#  histogram_range               :decimal(, )      not null
#  id                            :bigint(8)        not null, primary key
#  interquartile_range           :decimal(, )      not null
#  last_lead_time_p80            :decimal(, )      not null
#  last_throughput_per_week_data :integer          not null, is an Array
#  lead_time_histogram_bin_max   :decimal(, )      not null
#  lead_time_histogram_bin_min   :decimal(, )      not null
#  lead_time_max                 :decimal(, )      not null
#  lead_time_min                 :decimal(, )      not null
#  lead_time_p25                 :decimal(, )      not null
#  lead_time_p75                 :decimal(, )      not null
#  population_end_date           :date             not null
#  population_start_date         :date             not null
#  projects_ids                  :integer          not null, is an Array
#  team_id                       :integer          not null, indexed
#  total_range                   :decimal(, )      not null
#  updated_at                    :datetime         not null
#  wip_limit                     :integer          not null
#
# Indexes
#
#  index_flow_consolidations_on_team_id  (team_id)
#
# Foreign Keys
#
#  fk_rails_d5dbebc03a  (team_id => teams.id)
#

class FlowConsolidation < ApplicationRecord
  belongs_to :team

  validates :team, :average_customer_happiness, :consolidation_date, :current_wip, :demands_ids, :demands_lead_times, :demands_lead_times_average, :demands_lead_times_std_dev, :histogram_range,
            :interquartile_range, :last_lead_time_p80, :last_throughput_per_week_data, :lead_time_histogram_bin_max, :lead_time_histogram_bin_min, :lead_time_max, :lead_time_min, :lead_time_p25,
            :lead_time_p75, :population_end_date, :population_start_date, :projects_ids, :total_range, :wip_limit, :flow_pressure, :flow_total_cost, presence: true
end
