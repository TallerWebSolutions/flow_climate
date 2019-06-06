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
#  hours_per_month         :integer          not null
#  id                      :bigint(8)        not null, primary key
#  jira_account_user_email :string
#  monthly_payment         :decimal(, )      not null
#  name                    :string           not null
#  start_date              :date
#  team_id                 :integer          not null
#  updated_at              :datetime         not null
#
# Foreign Keys
#
#  fk_rails_194b5b076d  (team_id => teams.id)
#

class TeamMember < ApplicationRecord
  enum billable_type: { outsourcing: 0, consulting: 1, training: 2, domestic_product: 3 }

  belongs_to :team
  has_and_belongs_to_many :demands, dependent: :destroy

  validates :team, :name, :monthly_payment, :hours_per_month, presence: true

  scope :active, -> { where active: true }
end
