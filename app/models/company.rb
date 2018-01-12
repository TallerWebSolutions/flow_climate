# frozen_string_literal: true

# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Company < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :financial_informations, dependent: :restrict_with_error
  has_many :customers, dependent: :restrict_with_error
  has_many :team_members, dependent: :restrict_with_error
  has_many :operation_weekly_results, dependent: :restrict_with_error

  validates :name, presence: true

  def outsourcing_cost_per_week
    team_members.where(billable: true, billable_type: :outsourcing).sum(&:monthly_payment) / 4
  end

  def management_cost_per_week
    team_members.where(billable: false).sum(&:monthly_payment) / 4
  end

  def members_billable_count
    team_members.where(billable: true).count
  end

  def management_count
    team_members.where(billable: false).count
  end

  def active_projects_count
    customers.map(&:active_projects).flatten.count
  end

  def waiting_projects_count
    customers.map(&:waiting_projects).flatten.count
  end
end
