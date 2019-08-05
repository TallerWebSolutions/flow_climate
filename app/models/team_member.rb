# frozen_string_literal: true

# == Schema Information
#
# Table name: team_members
#
#  active                  :boolean          default(TRUE)
#  billable                :boolean          default(TRUE)
#  billable_type           :integer          default("outsourcing")
#  created_at              :datetime         not null
#  end_date                :date
#  hours_per_month         :integer
#  id                      :bigint(8)        not null, primary key
#  jira_account_id         :string           indexed => [team_id, name]
#  jira_account_user_email :string
#  monthly_payment         :decimal(, )
#  name                    :string           not null, indexed => [team_id, jira_account_id]
#  start_date              :date
#  team_id                 :integer          not null, indexed => [name, jira_account_id]
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_team_members_on_team_id_and_name_and_jira_account_id  (team_id,name,jira_account_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_194b5b076d  (team_id => teams.id)
#

class TeamMember < ApplicationRecord
  enum billable_type: { outsourcing: 0, consulting: 1, training: 2, domestic_product: 3 }

  belongs_to :team
  has_many :demand_comments, dependent: :nullify
  has_many :demand_blocks, inverse_of: :blocker, dependent: :destroy, foreign_key: :blocker_id
  has_many :demand_unblocks, class_name: 'DemandBlock', inverse_of: :unblocker, dependent: :destroy, foreign_key: :unblocker_id

  has_and_belongs_to_many :demands, dependent: :destroy

  validates :team, :name, presence: true
  validates :name, uniqueness: { scope: %i[team_id jira_account_id], message: I18n.t('activerecord.attributes.team_member.validations.name_unique') }

  scope :active, -> { where active: true }

  def to_hash
    { member_name: name, jira_account_id: jira_account_id }
  end
end
