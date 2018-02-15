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
#  index_teams_on_company_id           (company_id)
#  index_teams_on_company_id_and_name  (company_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#

class Team < ApplicationRecord
  include ProjectAggregator

  belongs_to :company
  has_many :team_members, dependent: :restrict_with_error
  has_many :project_results, dependent: :restrict_with_error
  has_many :projects, -> { distinct }, through: :project_results

  validates :company, :name, presence: true
  validates :name, uniqueness: { scope: :company, message: I18n.t('team.name.uniqueness') }

  delegate :count, to: :projects, prefix: true

  def outsourcing_cost
    team_members.active.where(billable: true, billable_type: :outsourcing).sum(&:total_monthly_payment)
  end

  def consulting_cost
    team_members.active.where(billable: true, billable_type: :consulting).sum(&:total_monthly_payment)
  end

  def management_cost
    team_members.active.where(billable: false).sum(&:total_monthly_payment)
  end

  def total_cost
    team_members.active.sum(&:total_monthly_payment)
  end

  def outsourcing_members_billable_count
    team_members.active.where(billable: true, billable_type: :outsourcing).count
  end

  def consulting_members_billable_count
    team_members.active.where(billable: true, billable_type: :consulting).count
  end

  def management_count
    team_members.active.where(billable: false).count
  end

  def current_outsourcing_monthly_available_hours
    team_members.active.where(billable: true, billable_type: :outsourcing).sum(&:hours_per_month)
  end

  def consumed_hours_in_month(required_date)
    project_results.in_month(required_date).sum(&:total_hours)
  end
end
