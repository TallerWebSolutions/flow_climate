# frozen_string_literal: true

# == Schema Information
#
# Table name: team_consolidations
#
#  id                                          :bigint           not null, primary key
#  bugs_share                                  :decimal(, )      default(0.0)
#  bugs_share_in_month                         :decimal(, )      default(0.0)
#  bugs_share_in_quarter                       :decimal(, )      default(0.0)
#  bugs_share_in_semester                      :decimal(, )      default(0.0)
#  bugs_share_in_year                          :decimal(, )      default(0.0)
#  consolidation_date                          :date             not null
#  consumed_hours_in_month                     :decimal(, )      default(0.0)
#  flow_efficiency                             :decimal(, )      default(0.0)
#  flow_efficiency_in_month                    :decimal(, )      default(0.0)
#  flow_efficiency_in_quarter                  :decimal(, )      default(0.0)
#  flow_efficiency_in_semester                 :decimal(, )      default(0.0)
#  flow_efficiency_in_year                     :decimal(, )      default(0.0)
#  hours_per_demand                            :decimal(, )      default(0.0)
#  hours_per_demand_in_month                   :decimal(, )      default(0.0)
#  hours_per_demand_in_quarter                 :decimal(, )      default(0.0)
#  hours_per_demand_in_semester                :decimal(, )      default(0.0)
#  hours_per_demand_in_year                    :decimal(, )      default(0.0)
#  last_data_in_month                          :boolean          default(FALSE)
#  last_data_in_week                           :boolean          default(FALSE)
#  last_data_in_year                           :boolean          default(FALSE)
#  lead_time_p80                               :decimal(, )      default(0.0)
#  lead_time_p80_in_month                      :decimal(, )      default(0.0)
#  lead_time_p80_in_quarter                    :decimal(, )      default(0.0)
#  lead_time_p80_in_semester                   :decimal(, )      default(0.0)
#  lead_time_p80_in_week                       :decimal(, )      default(0.0)
#  lead_time_p80_in_year                       :decimal(, )      default(0.0)
#  qty_bugs_closed                             :integer          default(0)
#  qty_bugs_closed_in_month                    :integer          default(0)
#  qty_bugs_closed_in_semester                 :integer          default(0)
#  qty_bugs_closed_in_year                     :integer          default(0)
#  qty_bugs_opened                             :integer          default(0)
#  qty_bugs_opened_in_month                    :integer          default(0)
#  qty_bugs_opened_in_quarter                  :integer          default(0)
#  qty_bugs_opened_in_semester                 :integer          default(0)
#  qty_bugs_opened_in_year                     :integer          default(0)
#  qty_demands_committed                       :integer          default(0)
#  qty_demands_committed_in_week               :integer          default(0)
#  qty_demands_created                         :integer          default(0)
#  qty_demands_created_in_week                 :integer          default(0)
#  qty_demands_finished_downstream             :integer          default(0)
#  qty_demands_finished_downstream_in_month    :integer          default(0)
#  qty_demands_finished_downstream_in_quarter  :integer          default(0)
#  qty_demands_finished_downstream_in_semester :integer          default(0)
#  qty_demands_finished_downstream_in_week     :integer          default(0)
#  qty_demands_finished_downstream_in_year     :integer          default(0)
#  qty_demands_finished_upstream               :integer          default(0)
#  qty_demands_finished_upstream_in_month      :integer          default(0)
#  qty_demands_finished_upstream_in_quarter    :integer          default(0)
#  qty_demands_finished_upstream_in_semester   :integer          default(0)
#  qty_demands_finished_upstream_in_week       :integer          default(0)
#  qty_demands_finished_upstream_in_year       :integer          default(0)
#  value_per_demand                            :decimal(, )      default(0.0)
#  value_per_demand_in_month                   :decimal(, )      default(0.0)
#  value_per_demand_in_quarter                 :decimal(, )      default(0.0)
#  value_per_demand_in_semester                :decimal(, )      default(0.0)
#  value_per_demand_in_year                    :decimal(, )      default(0.0)
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  team_id                                     :integer          not null
#
# Indexes
#
#  index_team_consolidations_on_last_data_in_month  (last_data_in_month)
#  index_team_consolidations_on_last_data_in_week   (last_data_in_week)
#  index_team_consolidations_on_last_data_in_year   (last_data_in_year)
#  index_team_consolidations_on_team_id             (team_id)
#  team_consolidation_unique                        (team_id,consolidation_date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_ee628d9f6b  (team_id => teams.id)
#
module Consolidations
  class TeamConsolidation < ApplicationRecord
    belongs_to :team

    scope :weekly_data, -> { where(last_data_in_week: true) }

    validates :team, :consolidation_date, presence: true
    validates :team, uniqueness: { scope: :consolidation_date }
  end
end
