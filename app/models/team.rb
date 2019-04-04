# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  company_id :integer          not null, indexed, indexed => [name]
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  name       :string           not null, indexed => [company_id]
#  updated_at :datetime         not null
#
# Indexes
#
#  index_teams_on_company_id           (company_id)
#  index_teams_on_company_id_and_name  (company_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_e080df8a94  (company_id => companies.id)
#

class Team < ApplicationRecord
  include ProjectAggregator

  belongs_to :company
  has_many :team_members, dependent: :destroy
  has_many :projects, dependent: :restrict_with_error
  has_many :products, dependent: :restrict_with_error
  has_many :product_projects, -> { distinct }, through: :products, source: :projects
  has_many :demands, -> { distinct }, through: :projects
  has_many :stages, dependent: :nullify

  validates :company, :name, presence: true
  validates :name, uniqueness: { scope: :company, message: I18n.t('team.name.uniqueness') }

  delegate :count, to: :projects, prefix: true

  def active_monthly_cost_for_billable_types(billable_type)
    team_members.active.where(billable: true, billable_type: billable_type).sum(&:monthly_payment)
  end

  def active_members_count_for_billable_types(billable_type)
    team_members.active.where(billable: true, billable_type: billable_type).count
  end

  def active_monthly_available_hours_for_billable_types(billable_type)
    team_members.active.where(billable: true, billable_type: billable_type).sum(&:hours_per_month)
  end

  def total_cost
    team_members.active.sum(&:monthly_payment)
  end

  def consumed_hours_in_month(required_date)
    demands.kept.where('EXTRACT(YEAR from demands.end_date) = :year AND EXTRACT(MONTH from demands.end_date) = :month', year: required_date.to_date.cwyear, month: required_date.to_date.month).sum(&:total_effort)
  end
end
