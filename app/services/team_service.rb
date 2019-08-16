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
      active_billable_members = team.team_members.joins(:memberships).where('start_date <= :end_date AND (end_date IS NULL OR end_date > :end_date) AND billable = true', end_date: end_date_to_cmd).where(memberships: { member_role: :developer })

      average_demand_cost = compute_average_demand_cost(active_billable_members, demands_count, grouping_period)

      average_demand_cost_hash[end_date_to_cmd] = average_demand_cost.to_f
    end

    average_demand_cost_hash
  end

  def average_demand_cost_stats_info_hash(team)
    five_weeks_cmd = compute_average_demand_cost_to_team(team, 5.weeks.ago.beginning_of_week.to_date, Time.zone.today.end_of_week.to_date, 'week')

    return if five_weeks_cmd.nil?

    four_weeks_cmd_array = five_weeks_cmd.values[-5, 4].compact
    four_weeks_cmd_average = four_weeks_cmd_array.sum / four_weeks_cmd_array.count

    compute_and_build_average_demand_cost_hash(five_weeks_cmd, four_weeks_cmd_average, team)
  end

  def compute_available_hours_to_team(team, start_date, end_date, grouping_period)
    hours_efficiency_hash = {}

    (start_date..end_date).each do |date|
      start_date_to_hours = start_of_period_for_date(date, grouping_period)
      end_date_to_hours = end_of_period_for_date(date, grouping_period)

      break if end_date_to_hours > end_of_period_for_date(Time.zone.today, grouping_period)

      hours_efficiency_hash[end_date_to_hours] = team.available_hours_at(start_date_to_hours.to_date, end_date_to_hours.to_date).to_f
    end

    hours_efficiency_hash
  end

  def compute_consumed_hours_to_team(team, start_date, end_date, grouping_period)
    hours_consumed_hash = {}

    (start_date..end_date).each do |date|
      start_date_to_hours = start_of_period_for_date(date, grouping_period)
      end_date_to_hours = end_of_period_for_date(date, grouping_period)

      break if end_date_to_hours > end_of_period_for_date(Time.zone.today, grouping_period)

      hours_consumed_hash[end_date_to_hours] = team.demands.to_end_dates(start_date_to_hours.to_date, end_date_to_hours.to_date).map(&:total_effort).sum.to_f
    end

    hours_consumed_hash
  end

  private

  def compute_and_build_average_demand_cost_hash(five_weeks_cmd, four_weeks_cmd_average, team)
    current_week = five_weeks_cmd.values[-1]
    last_week = five_weeks_cmd.values[-2] || 0

    cmd_difference_to_avg_last_four_weeks = 0
    cmd_difference_to_avg_last_four_weeks = ((current_week.to_f - four_weeks_cmd_average) / four_weeks_cmd_average) * 100 if four_weeks_cmd_average.positive?

    { team_name: team.name, current_week: current_week, last_week: last_week, cmd_difference_to_avg_last_four_weeks: cmd_difference_to_avg_last_four_weeks, four_weeks_cmd_average: four_weeks_cmd_average }
  end

  def compute_average_demand_cost(active_billable_members, demands_count, grouping_period)
    average_demand_cost = active_billable_members.map(&:monthly_payment).compact.sum / fraction_of_month_to_period(grouping_period)
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
