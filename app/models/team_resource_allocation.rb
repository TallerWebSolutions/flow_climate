# frozen_string_literal: true

# == Schema Information
#
# Table name: team_resource_allocations
#
#  created_at       :datetime         not null
#  end_date         :date
#  id               :bigint(8)        not null, primary key
#  monthly_payment  :decimal(, )      not null
#  start_date       :date             not null
#  team_id          :integer          not null, indexed
#  team_resource_id :integer          not null, indexed
#  updated_at       :datetime         not null
#
# Foreign Keys
#
#  fk_rails_600e78ae6c  (team_resource_id => team_resources.id)
#  fk_rails_e11bdf0f2c  (team_id => teams.id)
#

class TeamResourceAllocation < ApplicationRecord
  belongs_to :team
  belongs_to :team_resource

  validates :team, :team_resource, :start_date, :monthly_payment, presence: true
end
