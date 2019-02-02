# frozen_string_literal: true

class ReplenishingData
  attr_reader :team, :running_projects, :total_pressure, :summary_infos, :project_data_to_replenish

  def initialize(team)
    @team = team
    @running_projects = @team.projects.running.sort_by(&:flow_pressure).reverse
    @total_pressure = @running_projects.sum(&:flow_pressure)

    build_summary_infos
    build_replenishment_data
  end

  private

  def build_summary_infos
    if @running_projects.present?
      @summary_infos = { four_last_throughputs: ProjectsRepository.instance.throughput_per_week(running_projects, 4.weeks.ago, 1.week.ago).values }
      @summary_infos[:average_throughput] = @summary_infos[:four_last_throughputs].sum / @summary_infos[:four_last_throughputs].count
    else
      @summary_infos = {}
    end
  end

  def build_replenishment_data
    @project_data_to_replenish = []
    @running_projects.each { |project| @project_data_to_replenish << build_project_hash(project) }
  end

  def build_project_hash(project)
    project_data_to_replenish = {}
    project_data_to_replenish[:name] = project.full_name
    project_data_to_replenish[:end_date] = project.end_date
    project_data_to_replenish[:weeks_to_end_date] = project.remaining_weeks
    project_data_to_replenish[:remaining_backlog] = project.remaining_backlog
    project_data_to_replenish[:flow_pressure] = project.flow_pressure
    project_data_to_replenish[:relative_flow_pressure] = project.relative_flow_pressure(@total_pressure)
    project_data_to_replenish[:qty_using_pressure] = compute_qty_using_pressure(project)

    project_data_to_replenish[:work_in_progress] = project.demands.in_wip.count

    project_data_to_replenish = project_data_to_replenish.merge(build_stats_info(project))

    project_data_to_replenish[:customer_happiness] = compute_customer_happiness(project_data_to_replenish)
    project_data_to_replenish
  end

  def build_stats_info(project)
    stats_hash = {}
    stats_hash[:leadtime_80] = project.general_leadtime / 1.day
    throughput_data = ProjectsRepository.instance.throughput_per_week([project], project.start_date, 1.week.ago).values.last(15)
    stats_hash[:throughput_last_week] = throughput_data.last(1).last
    stats_hash[:montecarlo_80_percent] = build_monte_carlo_info(project, throughput_data)
    stats_hash
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
