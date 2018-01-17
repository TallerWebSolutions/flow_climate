# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_teams_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#

class Team < ApplicationRecord
  belongs_to :company
  has_many :team_members, dependent: :restrict_with_error
  has_many :project_results, dependent: :restrict_with_error

  validates :company, :name, presence: true

  def outsourcing_cost_per_week
    team_members.where(billable: true, billable_type: :outsourcing).sum(&:monthly_payment) / 4
  end

  def management_cost_per_week
    team_members.where(billable: false).sum(&:monthly_payment) / 4
  end

  def outsourcing_members_billable_count
    team_members.where(billable: true, billable_type: :outsourcing).count
  end

  def management_count
    team_members.where(billable: false).count
  end

  def current_outsourcing_monthly_available_hours
    team_members.where(billable: true, billable_type: :outsourcing).sum(&:hours_per_month)
  end
end
