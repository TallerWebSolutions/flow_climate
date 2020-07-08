# frozen_string_literal: true

# == Schema Information
#
# Table name: contract_consolidations
#
#  id                     :bigint           not null, primary key
#  consolidation_date     :date             not null
#  operational_risk_value :decimal(, )      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  contract_id            :integer          not null
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
class ContractConsolidation < ApplicationRecord
  belongs_to :contract

  validates :contract, :consolidation_date, :operational_risk_value, presence: true
end
