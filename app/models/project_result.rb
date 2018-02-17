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
  has_many :demands, dependent: :destroy

  validates :project, :team, :known_scope, :qty_hours_upstream, :qty_hours_downstream, :qty_hours_bug, :qty_bugs_closed, :qty_bugs_opened, :throughput, :result_date, presence: true

  scope :for_week, ->(week, year) { where('EXTRACT(WEEK FROM result_date) = :week AND EXTRACT(YEAR FROM result_date) = :year', week: week, year: year) }
  scope :until_week, ->(week, year) { where('(EXTRACT(WEEK FROM result_date) <= :week AND EXTRACT(YEAR FROM result_date) <= :year) OR (EXTRACT(YEAR FROM result_date) < :year)', week: week, year: year) }
  scope :in_month, ->(target_date) { where('result_date >= :start_date AND result_date <= :end_date', start_date: target_date.beginning_of_month, end_date: target_date.end_of_month) }

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
    available_hours = team.current_outsourcing_monthly_available_hours.to_f / 4 if team.present?
    update(remaining_days: project.remaining_days(result_date), flow_pressure: current_flow_pressure, cost_in_month: team&.outsourcing_cost, average_demand_cost: calculate_average_demand_cost, available_hours: available_hours)
  end

  def total_hours
    qty_hours_upstream + qty_hours_downstream
  end

  private

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
