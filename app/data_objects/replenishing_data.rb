# frozen_string_literal: true

class ReplenishingData
  attr_reader :team, :projects, :running_projects, :total_pressure, :summary_infos, :project_data_to_replenish

  def initialize(team)
    @team = team
    @projects = @team.projects.includes(:product)
    @running_projects = @projects.running.sort_by(&:flow_pressure).reverse
    @total_pressure = @running_projects.sum(&:flow_pressure)

    @start_date = 4.weeks.ago.beginning_of_week.to_date
    @end_date = 1.week.ago.end_of_week.to_date

    build_summary_infos
    build_replenishment_data
  end

  private

  def build_summary_infos
    if @projects.present?
      th_per_week_hash = DemandsRepository.instance.throughput_to_projects_and_period(projects, @start_date, @end_date).finished_with_leadtime.group('EXTRACT(WEEK FROM end_date)', 'EXTRACT(YEAR FROM end_date)').count
      build_basic_summary_infos(th_per_week_hash)
      @summary_infos[:average_throughput] = @summary_infos[:four_last_throughputs].sum / @summary_infos[:four_last_throughputs].count
    else
      @summary_infos = {}
    end
  end

  def build_basic_summary_infos(th_per_week_hash)
    @summary_infos = {
      four_last_throughputs: DemandInfoDataBuilder.instance.build_data_from_hash_per_week(th_per_week_hash, @start_date, @end_date).values,
      team_wip: @team.max_work_in_progress,
      team_lead_time: @team.lead_time(4.weeks.ago.beginning_of_week, 1.week.ago.end_of_week) / 1.day
    }
  end

  def build_replenishment_data
    @project_data_to_replenish = []
    @running_projects.each do |project|
      project_info_hash = build_project_hash(project)
      throughput_grouped_per_week_hash = build_grouped_per_week_hash(project).values

      project_info_hash = project_info_hash.merge(build_stats_info(project, throughput_grouped_per_week_hash))
      project_info_hash = project_info_hash.merge(build_qty_items_info(project))

      project_info_hash[:customer_happiness] = compute_customer_happiness(project_info_hash)
      @project_data_to_replenish << project_info_hash
    end
  end

  def build_project_hash(project)
    project_data_to_replenish = {}
    project_data_to_replenish[:id] = project.id
    project_data_to_replenish[:name] = project.full_name
    project_data_to_replenish[:start_date] = project.start_date
    project_data_to_replenish[:end_date] = project.end_date
    project_data_to_replenish[:weeks_to_end_date] = project.remaining_weeks
    project_data_to_replenish[:remaining_backlog] = project.remaining_backlog
    project_data_to_replenish[:leadtime_80] = project.general_leadtime / 1.day

    project_data_to_replenish[:aging_today] = project.aging_today
    project_data_to_replenish[:flow_pressure] = project.flow_pressure
    project_data_to_replenish[:relative_flow_pressure] = project.relative_flow_pressure(@total_pressure)
    project_data_to_replenish[:max_work_in_progress] = project.max_work_in_progress

    project_data_to_replenish
  end

  def build_stats_info(project, throughput_grouped_per_week_hash)
    stats_hash = {}

    stats_hash[:throughput_data] = throughput_grouped_per_week_hash.join(', ')
    stats_hash[:throughput_last_week] = throughput_grouped_per_week_hash.last
    stats_hash[:montecarlo_80_percent] = build_monte_carlo_info(project, throughput_grouped_per_week_hash.last(10))
    stats_hash[:project_based_risks_to_deadline] = project.current_risk_to_deadline
    stats_hash[:team_based_montecarlo_80_percent] = build_monte_carlo_info(project, build_project_share_in_team_throughput(project, build_team_throughput_per_week_data.values.last(10)))

    build_proejct_consolidation_data(project, stats_hash)

    stats_hash[:throughput_data_size] = throughput_grouped_per_week_hash.count

    stats_hash[:throughput_data_stddev] = Stats::StatisticsService.instance.standard_deviation(throughput_grouped_per_week_hash)
    stats_hash[:throughput_data_mode] = Stats::StatisticsService.instance.mode(throughput_grouped_per_week_hash)
    stats_hash
  end

  def build_proejct_consolidation_data(project, stats_hash)
    stats_hash[:team_based_odds_to_deadline] = project.last_project_consolidation&.odds_to_deadline_team
    stats_hash[:std_dev_weeks_montecarlo_team] = project.last_project_consolidation&.std_dev_weeks_montecarlo_team
    stats_hash[:min_weeks_montecarlo_team] = project.last_project_consolidation&.min_weeks_montecarlo_team
    stats_hash[:max_weeks_montecarlo_team] = project.last_project_consolidation&.max_weeks_montecarlo_team
  end

  def build_grouped_per_week_hash(project)
    throughput_data_per_week = DemandsRepository.instance.throughput_to_projects_and_period(project.product.projects.order(:end_date), build_minimum_date_in_product(project), 1.week.ago.end_of_week).finished_with_leadtime.group('EXTRACT(WEEK FROM end_date)', 'EXTRACT(YEAR FROM end_date)').count
    DemandInfoDataBuilder.instance.build_data_from_hash_per_week(throughput_data_per_week, project.start_date, 1.week.ago)
  end

  def build_minimum_date_in_product(project)
    project.product.projects.minimum(:start_date)
  end

  def build_team_throughput_per_week_data
    throughput_data_per_week = DemandsRepository.instance.throughput_to_projects_and_period(@projects.order(:end_date), minimum_date, 1.week.ago.end_of_week).finished_with_leadtime.group('EXTRACT(WEEK FROM end_date)', 'EXTRACT(YEAR FROM end_date)').count
    DemandInfoDataBuilder.instance.build_data_from_hash_per_week(throughput_data_per_week, minimum_date, 1.week.ago)
  end

  def minimum_date
    @minimum_date ||= @projects.minimum(:start_date)
  end

  def build_project_share_in_team_throughput(project, team_throughput_per_week_array)
    project_wip = project.max_work_in_progress
    team_wip = @team.max_work_in_progress
    project_share_in_flow = project_wip.to_f / team_wip.to_f

    team_throughput_per_week_array.map { |throughput| throughput * project_share_in_flow }
  end

  def build_qty_items_info(project)
    qty_items_hash = {}
    qty_items_hash[:qty_using_pressure] = compute_qty_using_pressure(project)
    qty_items_hash[:qty_selected_last_week] = DemandsRepository.instance.committed_demands_by_project_and_week([project], 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear).count
    qty_items_hash[:work_in_progress] = project.demands.in_wip.count
    qty_items_hash
  end

  def compute_customer_happiness(project_data_to_replenish)
    project_data_to_replenish[:weeks_to_end_date].to_f / project_data_to_replenish[:montecarlo_80_percent].to_f
  end

  def build_monte_carlo_info(project, throughput_data)
    montecarlo_durations = Stats::StatisticsService.instance.run_montecarlo(project.remaining_backlog, throughput_data, 100)
    Stats::StatisticsService.instance.percentile(80, montecarlo_durations)
  end

  def compute_qty_using_pressure(project)
    @summary_infos[:average_throughput] * (project.flow_pressure / @total_pressure)
  end
end
