# frozen_string_literal: true

# == Schema Information
#
# Table name: team_members
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  monthly_payment :decimal(, )      not null
#  hours_per_month :integer          not null
#  active          :boolean          default(TRUE)
#  billable        :boolean          default(TRUE)
#  billable_type   :integer          default("outsourcing")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_id         :integer          not null
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#

class TeamMember < ApplicationRecord
  enum billable_type: { outsourcing: 0, consulting: 1, training: 2 }

  belongs_to :team

  validates :team, :name, :monthly_payment, :hours_per_month, :billable_type, presence: true

  scope :active, -> { where active: true }
end
