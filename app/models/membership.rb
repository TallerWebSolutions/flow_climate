# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  created_at      :datetime         not null
#  end_date        :date
#  hours_per_month :integer
#  id              :bigint(8)        not null, primary key
#  member_role     :integer          default("developer"), not null
#  start_date      :date             not null
#  team_id         :integer          not null, indexed
#  team_member_id  :integer          not null, indexed
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_memberships_on_team_id         (team_id)
#  index_memberships_on_team_member_id  (team_member_id)
#
# Foreign Keys
#
#  fk_rails_1138510838  (team_member_id => team_members.id)
#  fk_rails_ae2aedcfaf  (team_id => teams.id)
#

class Membership < ApplicationRecord
  enum member_role: { developer: 0, manager: 1, client: 2 }

  belongs_to :team
  belongs_to :team_member

  validates :team, :team_member, :start_date, presence: true

  scope :active, -> { where('memberships.end_date IS NULL') }

  delegate :name, to: :team_member, prefix: true
  delegate :jira_account_id, to: :team_member
  delegate :monthly_payment, to: :team_member

  def hours_per_day
    hours_per_month.to_f / 30.0
  end
end
