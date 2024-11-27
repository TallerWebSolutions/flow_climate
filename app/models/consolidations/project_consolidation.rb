# frozen_string_literal: true

# == Schema Information
#
# Table name: project_consolidations
#
#  id                                            :bigint           not null, primary key
#  bugs_closed                                   :integer          default(0)
#  bugs_opened                                   :integer          default(0)
#  code_needed_blocks_count                      :integer          default(0)
#  code_needed_blocks_per_demand                 :decimal(, )      default(0.0)
#  consolidation_date                            :date             not null
#  current_wip                                   :integer
#  demands_finished_ids                          :integer          is an Array
#  demands_ids                                   :integer          is an Array
#  flow_efficiency                               :decimal(, )      default(0.0)
#  flow_efficiency_month                         :decimal(, )      default(0.0)
#  flow_pressure                                 :decimal(, )      default(0.0)
#  hours_per_demand                              :decimal(, )      default(0.0)
#  hours_per_demand_month                        :decimal(, )      default(0.0)
#  last_data_in_month                            :boolean          default(FALSE), not null
#  last_data_in_week                             :boolean          default(FALSE), not null
#  last_data_in_year                             :boolean          default(FALSE), not null
#  lead_time_average                             :decimal(, )      default(0.0)
#  lead_time_histogram_bin_max                   :decimal(, )      default(0.0)
#  lead_time_histogram_bin_min                   :decimal(, )      default(0.0)
#  lead_time_max                                 :decimal(, )      default(0.0)
#  lead_time_max_month                           :decimal(, )      default(0.0)
#  lead_time_min                                 :decimal(, )      default(0.0)
#  lead_time_min_month                           :decimal(, )      default(0.0)
#  lead_time_p25                                 :decimal(, )      default(0.0)
#  lead_time_p65                                 :decimal(, )      default(0.0)
#  lead_time_p75                                 :decimal(, )      default(0.0)
#  lead_time_p80                                 :decimal(, )      default(0.0)
#  lead_time_p80_month                           :decimal(, )      default(0.0)
#  lead_time_p95                                 :decimal(, )      default(0.0)
#  lead_time_std_dev                             :decimal(, )      default(0.0)
#  lead_time_std_dev_month                       :decimal(, )      default(0.0)
#  monte_carlo_weeks_max                         :integer          default(0)
#  monte_carlo_weeks_min                         :integer          default(0)
#  monte_carlo_weeks_p80                         :decimal(, )      default(0.0)
#  monte_carlo_weeks_std_dev                     :decimal(, )      default(0.0)
#  operational_risk                              :decimal(, )      default(0.0)
#  project_quality                               :decimal(, )      default(0.0)
#  project_scope                                 :integer          default(0)
#  project_scope_hours                           :integer          default(0)
#  project_throughput                            :integer          default(0)
#  project_throughput_hours                      :decimal(, )      default(0.0)
#  project_throughput_hours_additional           :float
#  project_throughput_hours_additional_in_month  :float
#  project_throughput_hours_design               :decimal(, )      default(0.0), not null
#  project_throughput_hours_design_in_month      :decimal(, )      default(0.0), not null
#  project_throughput_hours_development          :decimal(, )      default(0.0), not null
#  project_throughput_hours_development_in_month :decimal(, )      default(0.0), not null
#  project_throughput_hours_downstream           :decimal(, )      default(0.0)
#  project_throughput_hours_downstream_in_month  :decimal(, )
#  project_throughput_hours_in_month             :decimal(, )
#  project_throughput_hours_management           :decimal(, )      default(0.0), not null
#  project_throughput_hours_management_in_month  :decimal(, )      default(0.0), not null
#  project_throughput_hours_upstream             :decimal(, )      default(0.0)
#  project_throughput_hours_upstream_in_month    :decimal(, )
#  team_based_monte_carlo_weeks_max              :integer          default(0)
#  team_based_monte_carlo_weeks_min              :integer          default(0)
#  team_based_monte_carlo_weeks_p80              :decimal(, )      default(0.0)
#  team_based_monte_carlo_weeks_std_dev          :decimal(, )      default(0.0)
#  team_based_operational_risk                   :decimal(, )
#  value_per_demand                              :decimal(, )      default(0.0)
#  weeks_by_little_law                           :decimal(, )      default(0.0)
#  wip_limit                                     :integer
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  project_id                                    :integer          not null
#
# Foreign Keys
#
#  fk_rails_09ca62cd76  (project_id => projects.id)
#

module Consolidations
  class ProjectConsolidation < ApplicationRecord
    belongs_to :project

    validates :consolidation_date, presence: true

    scope :weekly_data, -> { where(last_data_in_week: true) }
    scope :for_project, ->(project) { where(project: project) }
    scope :after_date, ->(date) { where(consolidation_date: date..) }

    def lead_time_range
      return 0 if lead_time_max.nil? || lead_time_min.nil?

      lead_time_max - lead_time_min
    end

    def lead_time_range_month
      return 0 if lead_time_max_month.nil? || lead_time_min_month.nil?

      lead_time_max_month - lead_time_min_month
    end

    def histogram_range
      return 0 if lead_time_histogram_bin_max.nil? || lead_time_histogram_bin_min.nil?

      lead_time_histogram_bin_max - lead_time_histogram_bin_min
    end

    def interquartile_range
      return 0 if lead_time_p75.nil? || lead_time_p25.nil?

      lead_time_p75 - lead_time_p25
    end

    def lead_time_feature(percentil = 80)
      feature_demands = demands.kept.feature.filter_map(&:leadtime)
      @lead_time_feature ||= Stats::StatisticsService.instance.percentile(percentil, feature_demands)
    end

    def lead_time_bug(percentil = 80)
      bugs_lead_time_compact = demands.kept.bug.filter_map(&:leadtime)
      @lead_time_bug ||= Stats::StatisticsService.instance.percentile(percentil, bugs_lead_time_compact)
    end

    def lead_time_chore(percentil = 80)
      chore_demands = demands.kept.chore.filter_map(&:leadtime)
      @lead_time_chore ||= Stats::StatisticsService.instance.percentile(percentil, chore_demands)
    end

    def lead_time_standard(percentil = 80)
      standard_demands = demands.kept.standard.filter_map(&:leadtime)
      @lead_time_standard ||= Stats::StatisticsService.instance.percentile(percentil, standard_demands)
    end

    def lead_time_fixed_date(percentil = 80)
      fixed_date_demands = demands.kept.fixed_date.filter_map(&:leadtime)
      @lead_time_fixed_date ||= Stats::StatisticsService.instance.percentile(percentil, fixed_date_demands)
    end

    def lead_time_expedite(percentil = 80)
      expedite_demands = demands.kept.expedite.filter_map(&:leadtime)
      @lead_time_expedite ||= Stats::StatisticsService.instance.percentile(percentil, expedite_demands)
    end

    def last_data_for_month?
      last_data_in_month? || consolidation_date == Time.zone.today
    end

    def add_project_throughput_hours(added_hours)
      old_project_hours = project_throughput_hours || 0
      update(project_throughput_hours: old_project_hours + added_hours)
    end

    def add_project_throughput_hours_in_month(added_hours)
      old_project_hours = project_throughput_hours_in_month || 0
      update(project_throughput_hours_in_month: old_project_hours + added_hours)
    end

    private

    def demands
      @demands ||= Demand.where(id: demands_ids)
    end
  end
end
