# frozen_string_literal: true

class ReplenishingData
  attr_reader :team, :team_projects, :running_projects, :total_pressure, :summary_infos, :project_data_to_replenish, :throughput_per_period_array,
              :products_names, :customers_names

  def initialize(team)
    @team = team
    build_team_objects

    @start_date = 5.weeks.ago.beginning_of_week.to_date
    @end_date = 1.week.ago.end_of_week.to_date

    build_summary_infos
    build_replenishment_data
  end

  private

  def build_team_objects
    @team_projects = @team.projects
    @team_demands = @team.demands.includes([:team])
    @running_projects = @team_projects.includes(%i[customers products]).running.sort_by(&:flow_pressure).reverse
    @total_pressure = @running_projects.sum(&:flow_pressure)
  end

  def build_summary_infos
    if @running_projects.present? && @team_demands.present?
      th_for_team_per_week_hash = build_throughput_per_period_array(@team_demands, @start_date, @end_date, @running_projects.filter_map(&:initial_scope).sum)
      build_basic_summary_infos(th_for_team_per_week_hash)
      @summary_infos[:average_throughput] = @summary_infos[:four_last_throughputs].sum / @summary_infos[:four_last_throughputs].count
    else
      @summary_infos = {}
    end
  end

  def build_basic_summary_infos(th_per_week_hash)
    @summary_infos = {
      four_last_throughputs: th_per_week_hash.last(4),
      team_wip: @team.max_work_in_progress,
      team_lead_time: @team.lead_time(4.weeks.ago.beginning_of_week, 1.week.ago.end_of_week) / 1.day
    }
  end

  def build_replenishment_data
    @project_data_to_replenish = []
    @running_projects.each do |project|
      project_info_hash = build_project_hash(project)
      throughput_grouped_per_week_hash = build_throughput_per_period_array(project.demands.kept, project.start_date.beginning_of_week, 1.week.ago.end_of_week, project.initial_scope)

      project_info_hash = project_info_hash.merge(build_stats_info(project, throughput_grouped_per_week_hash))
      project_info_hash = project_info_hash.merge(build_qty_items_info(project))

      project_info_hash[:customer_happiness] = compute_customer_happiness(project_info_hash)
      @project_data_to_replenish << project_info_hash
    end
  end

  def build_project_hash(project)
    project_data_to_replenish = {}

    project_data_to_replenish[:id] = project.id
    project_data_to_replenish[:name] = project.name
    project_data_to_replenish[:start_date] = project.start_date
    project_data_to_replenish[:end_date] = project.end_date
    project_data_to_replenish[:weeks_to_end_date] = project.remaining_weeks
    project_data_to_replenish[:remaining_backlog] = project.remaining_backlog
    project_data_to_replenish[:leadtime_80] = project.general_leadtime

    project_data_to_replenish[:aging_today] = project.aging_today
    project_data_to_replenish[:flow_pressure] = project.flow_pressure
    project_data_to_replenish[:relative_flow_pressure] = project.relative_flow_pressure(@total_pressure)
    project_data_to_replenish[:max_work_in_progress] = project.max_work_in_progress
    project_data_to_replenish.merge(build_customers_products_names(project))
  end

  def build_stats_info(project, throughput_grouped_per_week_hash)
    stats_hash = {}

    stats_hash[:throughput_data] = throughput_grouped_per_week_hash
    stats_hash[:throughput_last_week] = throughput_grouped_per_week_hash.last
    stats_hash[:montecarlo_80_percent] = build_monte_carlo_info(project, throughput_grouped_per_week_hash.last(10))
    stats_hash[:project_based_risks_to_deadline] = project.current_risk_to_deadline
    stats_hash[:team_based_montecarlo_80_percent] = build_monte_carlo_info(project, build_project_share_in_team_throughput(project, build_throughput_per_period_array(@team_demands, @start_date, @end_date, uncertain_scope_for_team).last(10)))

    build_team_based_consolidation_data(project.last_project_consolidation, stats_hash)

    stats_hash[:throughput_data_size] = throughput_grouped_per_week_hash.count

    stats_hash
  end

  def uncertain_scope_for_team
    @team_projects.filter_map(&:initial_scope).sum
  end

  def build_team_based_consolidation_data(project_consolidation, stats_hash)
    stats_hash[:team_based_odds_to_deadline] = 1 - (project_consolidation&.team_based_operational_risk || 0)
    stats_hash[:team_monte_carlo_weeks_std_dev] = project_consolidation&.team_based_monte_carlo_weeks_std_dev || 0
    stats_hash[:team_monte_carlo_weeks_min] = project_consolidation&.team_based_monte_carlo_weeks_min || 0
    stats_hash[:team_monte_carlo_weeks_max] = project_consolidation&.team_based_monte_carlo_weeks_max || 0
  end

  def build_throughput_per_period_array(demands, start_date, end_date, initial_scope)
    dates_array = TimeService.instance.weeks_between_of(start_date, end_date)
    work_item_flow_information = Flow::WorkItemFlowInformations.new(demands, initial_scope, dates_array.length, dates_array.last, 'week')

    dates_array.each_with_index do |analysed_date, distribution_index|
      work_item_flow_information.work_items_flow_behaviour(dates_array.first, analysed_date, distribution_index, true)
    end
    @throughput_per_period_array = work_item_flow_information.throughput_per_period
  end

  def build_project_share_in_team_throughput(project, team_throughput_per_week_array)
    project_wip = project.max_work_in_progress
    team_wip = @team.max_work_in_progress
    project_share_in_flow = 0
    project_share_in_flow = project_wip.to_f / team_wip if team_wip.positive?

    team_throughput_per_week_array.map { |throughput| throughput * project_share_in_flow }
  end

  def build_qty_items_info(project)
    qty_items_hash = {}
    qty_items_hash[:qty_using_pressure] = compute_qty_using_pressure(project)
    qty_items_hash[:qty_selected_last_week] = DemandsRepository.instance.committed_demands_to_period(project.demands, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear).count
    qty_items_hash[:work_in_progress] = project.demands.in_wip.count
    qty_items_hash
  end

  def compute_customer_happiness(project_data_to_replenish)
    return 0 unless project_data_to_replenish[:montecarlo_80_percent].positive?

    project_data_to_replenish[:weeks_to_end_date].to_f / project_data_to_replenish[:montecarlo_80_percent]
  end

  def build_monte_carlo_info(project, throughput_data)
    montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(project.remaining_work, throughput_data, 100)
    Stats::StatisticsService.instance.percentile(80, montecarlo_durations)
  end

  def compute_qty_using_pressure(project)
    return 0 if @total_pressure.blank? || @total_pressure.zero? || @summary_infos.blank?

    @summary_infos[:average_throughput] * (project.flow_pressure / @total_pressure)
  end

  def build_customers_products_names(project)
    customers_products_names_hash = {}
    customers_products_names_hash[:customers_names] = project.customers.map(&:name)
    customers_products_names_hash[:products_names] = project.products.map(&:name)
    customers_products_names_hash
  end
end
