# frozen_string_literal: true

# == Schema Information
#
# Table name: operations_dashboard_pairings
#
#  id                      :bigint           not null, primary key
#  pair_times              :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  operations_dashboard_id :integer          not null
#  pair_id                 :integer
#
# Indexes
#
#  index_operations_dashboard_pairings_on_operations_dashboard_id  (operations_dashboard_id)
#  index_operations_dashboard_pairings_on_pair_id                  (pair_id)
#  operations_dashboard_pairings_cache_unique                      (operations_dashboard_id,pair_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_db85e736aa  (operations_dashboard_id => operations_dashboards.id)
#  fk_rails_ea51fcd7c0  (pair_id => team_members.id)
#

module Dashboards
  class OperationsDashboardPairing < ApplicationRecord
    belongs_to :operations_dashboard
    belongs_to :pair, class_name: 'TeamMember', optional: true

    validates :pair_times, presence: true

    scope :before_date, ->(date) { where('operations_dashboards.dashboard_date <= :date', date: date) }
    scope :for_team_member, ->(pair, team_member) { joins(operations_dashboard: :team_member).where(pair: pair, operations_dashboards: { team_member: team_member }) }
  end
end
