# frozen_string_literal: true

# == Schema Information
#
# Table name: contract_estimation_change_histories
#
#  id               :integer          not null, primary key
#  contract_id      :integer          not null
#  change_date      :datetime         not null
#  hours_per_demand :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ContractEstimationChangeHistory < ApplicationRecord
  belongs_to :contract

  validates :change_date, :hours_per_demand, presence: true
end
