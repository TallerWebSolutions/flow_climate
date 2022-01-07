# frozen-string-literal: true

# == Schema Information
#
# Table name: contract_estimation_change_histories
#
#  id               :bigint           not null, primary key
#  change_date      :datetime         not null
#  hours_per_demand :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  contract_id      :integer          not null
#
# Foreign Keys
#
#  fk_rails_61bdbf3322  (contract_id => contracts.id)
#

class ContractEstimationChangeHistory < ApplicationRecord
  belongs_to :contract

  validates :change_date, :hours_per_demand, presence: true
end
