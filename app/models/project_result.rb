# frozen_string_literal: true

# == Schema Information
#
# Table name: project_results
#
#  id                    :integer          not null, primary key
#  project_id            :integer          not null
#  result_date           :date             not null
#  known_scope           :integer          not null
#  qty_hours_upstream    :integer          not null
#  qty_hours_downstream  :integer          not null
#  qty_bugs_opened       :integer          not null
#  qty_bugs_closed       :integer          not null
#  qty_hours_bug         :integer          not null
#  leadtime              :decimal(, )
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  team_id               :integer          not null
#  monte_carlo_date      :date
#  demands_count         :integer
#  flow_pressure         :decimal(, )      not null
#  remaining_days        :integer          not null
#  cost_in_month         :decimal(, )      not null
#  average_demand_cost   :decimal(, )      not null
#  available_hours       :decimal(, )      not null
#  manual_input          :boolean          default(FALSE)
#  throughput_upstream   :integer          default(0)
#  throughput_downstream :integer          default(0)
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
  has_many :demands, dependent: :restrict_with_error

  validates :project, :team, :known_scope, :qty_hours_upstream, :qty_hours_downstream, :qty_hours_bug, :qty_bugs_closed, :qty_bugs_opened, :throughput_upstream, :throughput_downstream, :result_date, presence: true

  scope :for_week, ->(week, year) { where('EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', week: week, year: year) }
  scope :until_week, ->(week, year) { where('(EXTRACT(WEEK FROM result_date) <= :week AND EXTRACT(YEAR FROM result_date) <= :year) OR (EXTRACT(YEAR FROM result_date) < :year)', week: week, year: year) }
  scope :in_month, ->(target_date) { where('result_date >= :start_date AND result_date <= :end_date', start_date: target_date.beginning_of_month, end_date: target_date.end_of_month) }
  scope :manual_results, -> { left_outer_joins(demands: :demand_transitions).where('demand_transitions.id IS NULL').order(:result_date) }

  delegate :name, to: :team, prefix: true

  validate :result_date_greater_than_project_end_date

  def project_delivered_hours
    qty_hours_upstream + qty_hours_downstream
  end

  def hours_per_demand_upstream
    return 0 if throughput_upstream.zero?
    qty_hours_upstream.to_f / throughput_upstream.to_f
  end

  def hours_per_demand_downstream
    return 0 if throughput_downstream.zero?
    qty_hours_downstream.to_f / throughput_downstream.to_f
  end

  def define_automatic_attributes!
    available_hours = team.active_daily_available_hours_for_billable_types([project.project_type])
    team_cost_in_month = team.active_monthly_cost_for_billable_types([project.project_type])
    update(known_scope: current_scope, remaining_days: project.remaining_days(result_date), flow_pressure: current_flow_pressure, cost_in_month: team_cost_in_month,
           available_hours: available_hours, average_demand_cost: compute_average_demand_cost, leadtime: demands.finished.average(:leadtime))
  end

  def total_hours
    qty_hours_upstream + qty_hours_downstream
  end

  def add_demand!(demand)
    demands << demand unless demands.include?(demand)
    ProjectResult.reset_counters(id, :demands_count) if id.present?
    demand.update(project_result: self)
    compute_flow_metrics!
  end

  def remove_demand!(demand)
    demand.update(project_result: nil) if demands.include?(demand)
    ProjectResult.reset_counters(id, :demands_count)
    return destroy if demands.count.zero?
    compute_flow_metrics!
  end

  def compute_flow_metrics!
    finished_upstream_demands = demands.finished_in_stream(Stage.stage_streams[:upstream])
    finished_downstream_demands = demands.finished_in_stream(Stage.stage_streams[:downstream])
    finished_bugs = demands.finished_bugs.uniq
    open_bugs = demands.bug.opened_in_date(result_date).uniq

    update_result!(finished_upstream_demands, finished_downstream_demands, finished_bugs, open_bugs)
  end

  private

  def update_result!(finished_upstream_demands, finished_downstream_demands, finished_bugs, opened_bugs)
    remaining_days = project.remaining_days(result_date)
    update(known_scope: current_scope, throughput_upstream: finished_upstream_demands.count, throughput_downstream: finished_downstream_demands.count, qty_hours_upstream: finished_upstream_demands.sum(&:effort_upstream),
           qty_hours_downstream: finished_downstream_demands.sum(&:effort_downstream), qty_hours_bug: finished_bugs.sum(&:effort_downstream), qty_bugs_closed: finished_bugs.count, qty_bugs_opened: opened_bugs.count,
           remaining_days: remaining_days, flow_pressure: current_flow_pressure, average_demand_cost: compute_average_demand_cost(finished_upstream_demands + finished_downstream_demands),
           leadtime: demands.finished.average(:leadtime))
  end

  def cost_per_day
    return 0 if cost_in_month.blank?
    cost_in_month / 30
  end

  def compute_average_demand_cost(finished_demands = nil)
    throughput_for_result = throughput_upstream + throughput_downstream
    throughput_for_result = finished_demands.count if finished_demands.present?
    return 0 if cost_per_day.zero? || throughput_for_result.zero?
    cost_per_day / throughput_for_result.to_f
  end

  def current_gap
    current_scope - project.total_throughput_until(result_date)
  end

  def current_flow_pressure
    return 0 if project.remaining_days(result_date).zero? || current_gap.to_f <= 0
    current_gap.to_f / project.remaining_days(result_date).to_f
  end

  def result_date_greater_than_project_end_date
    return true if (result_date.blank? || project.start_date.blank?) || (result_date <= project.end_date)
    errors.add(:result_date, I18n.t('project_result.validations.result_date_greater_than_project_start_date'))
  end

  def current_scope
    DemandsRepository.instance.known_scope_to_date(project, result_date) + project.initial_scope
  end
end
