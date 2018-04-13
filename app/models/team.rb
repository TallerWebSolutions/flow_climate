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
  has_many :products, dependent: :restrict_with_error
  has_many :pipefy_team_configs, class_name: 'Pipefy::PipefyTeamConfig', dependent: :destroy, inverse_of: :team

  validates :company, :name, presence: true
  validates :name, uniqueness: { scope: :company, message: I18n.t('team.name.uniqueness') }

  delegate :count, to: :projects, prefix: true

  def active_monthly_cost_for_billable_types(billable_type)
    team_members.active.where(billable: true, billable_type: billable_type).sum(&:total_monthly_payment)
  end

  def active_members_count_for_billable_types(billable_type)
    team_members.active.where(billable: true, billable_type: billable_type).count
  end

  def active_monthly_available_hours_for_billable_types(billable_type)
    team_members.active.where(billable: true, billable_type: billable_type).sum(&:hours_per_month)
  end

  def active_daily_available_hours_for_billable_types(billable_type)
    active_monthly_available_hours_for_billable_types(billable_type) / 30.0
  end

  def total_cost
    team_members.active.sum(&:total_monthly_payment)
  end

  def consumed_hours_in_month(required_date)
    project_results.in_month(required_date).sum(&:total_hours)
  end
end
