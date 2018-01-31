# frozen_string_literal: true

# == Schema Information
#
# Table name: companies
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  abbreviation    :string           not null
#  customers_count :integer          default(0)
#

class Company < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :financial_informations, dependent: :restrict_with_error
  has_many :customers, dependent: :restrict_with_error
  has_many :products, through: :customers
  has_many :projects, through: :customers
  has_many :teams, dependent: :restrict_with_error
  has_many :operation_results, dependent: :restrict_with_error
  has_many :project_risk_configs, dependent: :destroy

  validates :name, :abbreviation, presence: true

  def add_user(user)
    return if users.include?(user)
    users << user
  end

  def outsourcing_cost
    teams.sum(&:outsourcing_cost)
  end

  def management_cost
    teams.sum(&:management_cost)
  end

  def outsourcing_members_billable_count
    teams.sum(&:outsourcing_members_billable_count)
  end

  def management_count
    teams.sum(&:management_count)
  end

  def active_projects_count
    customers.sum { |p| p.active_projects.count }
  end

  def waiting_projects_count
    customers.sum { |p| p.waiting_projects.count }
  end

  def projects_count
    customers.sum(&:projects_count)
  end

  def products_count
    customers.sum(&:products_count)
  end

  def last_cost_per_hour
    finance = financial_informations.order(finances_date: :desc).first
    finance&.cost_per_hour
  end

  def last_hours_per_demand
    finance = financial_informations.order(finances_date: :desc).first
    finance&.hours_per_demand
  end

  def last_throughput
    finance = financial_informations.order(finances_date: :desc).first
    finance&.throughput_operation_result
  end

  def current_backlog
    customers.sum(&:current_backlog)
  end

  def avg_hours_per_demand
    customers.sum(&:avg_hours_per_demand) / customers_count.to_f
  end

  def current_outsourcing_monthly_available_hours
    teams.sum(&:current_outsourcing_monthly_available_hours)
  end

  def consumed_hours_in_week(week, year)
    ProjectResultsRepository.instance.consumed_hours_in_week(self, week, year)
  end

  def th_in_week(week, year)
    ProjectResultsRepository.instance.th_in_week(self, week, year)
  end

  def bugs_opened_in_week(week, year)
    ProjectResultsRepository.instance.bugs_opened_in_week(self, week, year)
  end

  def bugs_closed_in_week(week, year)
    ProjectResultsRepository.instance.bugs_closed_in_week(self, week, year)
  end

  def top_three_flow_pressure
    projects.sort_by(&:flow_pressure).reverse.first(3)
  end

  def next_starting_project
    projects.waiting.order(:start_date).first
  end

  def next_finishing_project
    projects.executing.order(:end_date).first
  end
end
