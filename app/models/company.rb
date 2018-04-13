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
  has_many :pipefy_configs, class_name: 'Pipefy::PipefyConfig', dependent: :destroy, inverse_of: :company
  has_many :stages, dependent: :restrict_with_error
  has_one :company_settings, dependent: :destroy

  validates :name, :abbreviation, presence: true

  def add_user(user)
    return if users.include?(user)
    users << user
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

  def current_cost_per_hour
    finance = financial_informations.where('finances_date <= current_date').order(finances_date: :desc).first
    return 0 if finance.blank?
    return compute_current_cost_per_hour(finance) if consumed_hours_in_month.positive?
    finance.expenses_total
  end

  def current_hours_per_demand
    consumed_hours_in_month.to_f / current_month_throughput.to_f if current_month_throughput.positive?
    consumed_hours_in_month
  end

  def current_month_throughput
    @current_month_throughput ||= (ProjectResultsRepository.instance.upstream_throughput_in_month_for_company(self) + ProjectResultsRepository.instance.downstream_throughput_in_month_for_company(self))
  end

  def last_week_scope
    customers.sum(&:last_week_scope)
  end

  def avg_hours_per_demand
    customers.sum(&:avg_hours_per_demand) / customers_count.to_f
  end

  def consumed_hours_in_month(date = Time.zone.today)
    @consumed_hours_in_month ||= ProjectResultsRepository.instance.consumed_hours_in_month(self, date)
  end

  def throughput_in_month(date = Time.zone.today)
    ProjectResultsRepository.instance.upstream_throughput_in_month_for_company(self, date) + ProjectResultsRepository.instance.downstream_throughput_in_month_for_company(self, date)
  end

  def bugs_opened_in_month(date = Time.zone.today)
    ProjectResultsRepository.instance.bugs_opened_in_month(self, date)
  end

  def bugs_closed_in_month(date = Time.zone.today)
    ProjectResultsRepository.instance.bugs_closed_in_month(self, date)
  end

  def top_three_flow_pressure
    projects.running.sort_by(&:flow_pressure).reverse.first(3)
  end

  def top_three_throughput
    projects.sort_by { |project| project.total_throughput_for(1.week.ago.to_date) }.reverse.first(3)
  end

  def next_starting_project
    projects.waiting.order(:start_date).first
  end

  def next_finishing_project
    projects.running.order(:end_date).first
  end

  def demands_delivered_last_week
    DemandsRepository.instance.demands_for_company_and_week(self, 1.week.ago.to_date)
  end

  def total_active_hours
    projects.active.sum(:qty_hours)
  end

  def total_active_consumed_hours
    projects.active.sum(&:total_hours_consumed)
  end

  def total_available_hours
    total_available = 0
    teams.sum { |team| total_available += team.active_monthly_available_hours_for_billable_types(projects.pluck(:project_type).uniq) }
    total_available
  end

  private

  def compute_current_cost_per_hour(finance)
    finance.expenses_total / consumed_hours_in_month
  end
end
