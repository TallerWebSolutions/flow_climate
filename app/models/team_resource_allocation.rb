# frozen_string_literal: true

# == Schema Information
#
# Table name: team_resource_allocations
#
#  id               :integer          not null, primary key
#  team_resource_id :integer          not null
#  team_id          :integer          not null
#  monthly_payment  :decimal(, )      not null
#  start_date       :date             not null
#  end_date         :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_team_resource_allocations_on_team_id           (team_id)
#  index_team_resource_allocations_on_team_resource_id  (team_resource_id)
#

class TeamResourceAllocation < ApplicationRecord
  belongs_to :team
  belongs_to :team_resource

  validates :start_date, :monthly_payment, presence: true

  scope :active_for_date, ->(limit_date) { where('start_date <= :limit_date AND (end_date IS NULL OR end_date > :limit_date)', limit_date: limit_date) }
end
