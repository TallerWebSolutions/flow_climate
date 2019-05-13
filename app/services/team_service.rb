# frozen_string_literal: true

class TeamService
  include Singleton

  def compute_average_demand_cost_to_team(team, start_date, end_date, grouping_period)
    projects = team.projects

    average_demand_cost_hash = {}

    (start_date..end_date).each do |date|
      start_date_to_cmd = start_of_period_for_date(date, grouping_period)
      end_date_to_cmd = end_of_period_for_date(date, grouping_period)

      break if end_date_to_cmd > end_of_period_for_date(Time.zone.today, grouping_period)

      demands_count = DemandsRepository.instance.throughput_to_projects_and_period(projects, start_date_to_cmd, end_date_to_cmd).count
      active_members = team.team_members.where('start_date <= :end_date AND (end_date IS NULL OR end_date > :end_date)', end_date: end_date_to_cmd)

      average_demand_cost = compute_average_demand_cost(active_members, demands_count, grouping_period)

      average_demand_cost_hash[end_date_to_cmd] = average_demand_cost.to_f
    end

    average_demand_cost_hash
  end

  private

  def compute_average_demand_cost(active_members, demands_count, grouping_period)
    average_demand_cost = active_members.sum(&:monthly_payment) / fraction_of_month_to_period(grouping_period)
    average_demand_cost = (average_demand_cost / demands_count.to_f) if demands_count.positive?
    average_demand_cost
  end

  def start_of_period_for_date(date, grouping_period)
    return date.beginning_of_day if grouping_period == 'day'
    return date.beginning_of_week if grouping_period == 'week'

    date.beginning_of_month
  end

  def end_of_period_for_date(date, grouping_period)
    return date if grouping_period == 'day'
    return date.end_of_week if grouping_period == 'week'

    date.end_of_month
  end

  def fraction_of_month_to_period(grouping_period)
    return 30.0 if grouping_period == 'day'
    return 4.0 if grouping_period == 'week'

    1.0
  end
end
