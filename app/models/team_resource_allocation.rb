# frozen_string_literal: true

# == Schema Information
#
# Table name: team_resource_allocations
#
#  id               :bigint           not null, primary key
#  end_date         :date
#  monthly_payment  :decimal(, )      not null
#  start_date       :date             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  team_id          :integer          not null
#  team_resource_id :integer          not null
#
# Indexes
#
#  index_team_resource_allocations_on_team_id           (team_id)
#  index_team_resource_allocations_on_team_resource_id  (team_resource_id)
#
# Foreign Keys
#
#  fk_rails_600e78ae6c  (team_resource_id => team_resources.id)
#  fk_rails_e11bdf0f2c  (team_id => teams.id)
#

class TeamResourceAllocation < ApplicationRecord
  belongs_to :team
  belongs_to :team_resource

  validates :start_date, :monthly_payment, presence: true

  scope :active_for_date, ->(limit_date) { where('start_date <= :limit_date AND (end_date IS NULL OR end_date > :limit_date)', limit_date: limit_date) }
end
