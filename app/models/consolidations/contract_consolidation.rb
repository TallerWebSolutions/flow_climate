# frozen_string_literal: true

# == Schema Information
#
# Table name: contract_consolidations
#
#  id                                  :bigint           not null, primary key
#  consolidation_date                  :date             not null
#  design_consumed_hours               :decimal(, )      default(0.0), not null
#  design_consumed_hours_in_month      :decimal(, )      default(0.0), not null
#  development_consumed_hours          :decimal(, )      default(0.0), not null
#  development_consumed_hours_in_month :decimal(, )      default(0.0), not null
#  estimated_hours_per_demand          :integer
#  management_consumed_hours           :decimal(, )      default(0.0), not null
#  management_consumed_hours_in_month  :decimal(, )      default(0.0), not null
#  max_monte_carlo_weeks               :integer          default(0)
#  min_monte_carlo_weeks               :integer          default(0)
#  monte_carlo_duration_p80_weeks      :integer          default(0)
#  operational_risk_value              :decimal(, )      not null
#  real_hours_per_demand               :integer
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  contract_id                         :integer          not null
#
# Indexes
#
#  idx_contract_consolidation_unique                    (contract_id,consolidation_date) UNIQUE
#  index_contract_consolidations_on_consolidation_date  (consolidation_date)
#  index_contract_consolidations_on_contract_id         (contract_id)
#
# Foreign Keys
#
#  fk_rails_3ff1f4bb7a  (contract_id => contracts.id)
#

module Consolidations
  class ContractConsolidation < ApplicationRecord
    belongs_to :contract

    validates :consolidation_date, :operational_risk_value, presence: true
  end
end
