# frozen_string_literal: true

# == Schema Information
#
# Table name: project_results
#
#  id                   :integer          not null, primary key
#  project_id           :integer          not null
#  result_date          :date             not null
#  known_scope          :integer          not null
#  qty_hours_upstream   :integer          not null
#  qty_hours_downstream :integer          not null
#  throughput           :integer          not null
#  qty_bugs_opened      :integer          not null
#  qty_bugs_closed      :integer          not null
#  qty_hours_bug        :integer          not null
#  leadtime             :decimal(, )
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  team_id              :integer          not null
#  monte_carlo_date     :date
#  demands_count        :integer
#  flow_pressure        :decimal(, )      not null
#  remaining_days       :integer          not null
#  cost_in_month        :decimal(, )      not null
#  average_demand_cost  :decimal(, )      not null
#  available_hours      :decimal(, )      not null
#
# Indexes
#
#  index_project_results_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (team_id => teams.id)
#

class ProjectResult < ApplicationRecord
  belongs_to :team
  belongs_to :project
  has_many :demands, dependent: :nullify

  validates :project, :team, :known_scope, :qty_hours_upstream, :qty_hours_downstream, :qty_hours_bug, :qty_bugs_closed, :qty_bugs_opened, :throughput, :result_date, presence: true

  scope :for_week, ->(week, year) { where('EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', week: week, year: year) }
  scope :until_week, ->(week, year) { where('(EXTRACT(WEEK FROM result_date) <= :week AND EXTRACT(YEAR FROM result_date) <= :year) OR (EXTRACT(YEAR FROM result_date) < :year)', week: week, year: year) }
  scope :in_month, ->(target_date) { where('result_date >= :start_date AND result_date <= :end_date', start_date: target_date.beginning_of_month, end_date: target_date.end_of_month) }
  scope :manual_results, -> { left_outer_joins(demands: :demand_transitions).where('demand_transitions.id IS NULL').order(:result_date) }

  delegate :name, to: :team, prefix: true

  validate :result_date_less_than_project_start_date, :result_date_greater_than_project_start_date

  def project_delivered_hours
    qty_hours_upstream + qty_hours_downstream
  end

  def hours_per_demand
    return 0 if throughput.zero?
    project_delivered_hours / throughput
  end

  def define_automatic_attributes!
    available_hours = 0
    available_hours = available_hours_per_day if team.present?
    update(remaining_days: project.remaining_days(result_date), flow_pressure: current_flow_pressure, cost_in_month: team&.outsourcing_cost, average_demand_cost: calculate_average_demand_cost, available_hours: available_hours)
  end

  def total_hours
    qty_hours_upstream + qty_hours_downstream
  end

  def add_demand!(demand)
    demands << demand unless demands.include?(demand)
    compute_flow_metrics!
    save
  end

  def remove_demand!(demand)
    demands.delete(demand) if demands.include?(demand)
    return destroy if demands.count.zero?
    compute_flow_metrics!
  end

  def compute_flow_metrics!
    finished_in_date = project.demands.finished_in_date(result_date)
    finished_bugs = project.demands.bug.finished_in_date(result_date)

    update_result!(finished_bugs, finished_in_date)
  end

  private

  def available_hours_per_day
    team.current_outsourcing_monthly_available_hours.to_f / 30
  end

  def compute_known_scope
    results_without_transitions = project.project_results.manual_results

    known_scope = DemandsRepository.instance.known_scope_to_date(project, result_date)
    known_scope += results_without_transitions.last.known_scope if results_without_transitions.present?
    known_scope
  end

  def update_result!(finished_bugs, finished_demands)
    update(known_scope: compute_known_scope, throughput: finished_demands.count, qty_hours_upstream: 0, qty_hours_downstream: finished_demands.sum(&:effort),
           qty_hours_bug: finished_bugs.sum(&:effort), qty_bugs_closed: finished_bugs.count, qty_bugs_opened: project.demands.bugs_opened_in_date_count(result_date),
           remaining_days: project.remaining_days(result_date), flow_pressure: compute_flow_pressure, average_demand_cost: compute_average_demand_cost)
  end

  def compute_flow_pressure
    project.total_gap / project.remaining_days(result_date)
  end

  def compute_average_demand_cost
    cost_per_day / demands.count.to_f
  end

  def cost_per_day
    cost_in_month / 30
  end

  def calculate_average_demand_cost
    return 0 if team.blank? || team.outsourcing_cost&.zero? || throughput.zero?
    (team.outsourcing_cost / 30) / throughput.to_f
  end

  def current_gap
    known_scope - project.project_results.for_week(result_date.cweek, result_date.cwyear).sum(&:throughput)
  end

  def current_flow_pressure
    return 0 if project.remaining_days(result_date).zero?
    current_gap.to_f / project.remaining_days(result_date).to_f
  end

  def result_date_less_than_project_start_date
    return true if (result_date.blank? || project.start_date.blank?) || (result_date >= project.start_date)
    errors.add(:result_date, I18n.t('project_result.validations.result_date_less_than_project_start_date'))
  end

  def result_date_greater_than_project_start_date
    return true if (result_date.blank? || project.start_date.blank?) || (result_date <= project.end_date)
    errors.add(:result_date, I18n.t('project_result.validations.result_date_greater_than_project_start_date'))
  end
end
