# frozen_string_literal: true

class DemandBlocksRepository
  include Singleton

  def closed_blocks_to_projects_and_period_grouped(projects, start_date, end_date)
    active_blocks_to_projects_and_period(projects, start_date, end_date).closed.order('demand_blocks.unblock_time ASC').group_by { |demand_block| demand_block.demand.project.full_name }
  end

  def active_blocks_to_projects_and_period(projects, start_date, end_date)
    DemandBlock.active
               .joins(demand: :project)
               .where(projects: { id: projects.map(&:id) })
               .where('demand_blocks.block_time >= :start_date AND demand_blocks.block_time <= :end_date', start_date: start_date.beginning_of_day, end_date: end_date.end_of_day)
  end

  def accumulated_blocks_to_date(projects, end_date)
    DemandBlock.closed
               .active
               .joins(demand: :project)
               .where(projects: { id: projects.map(&:id) })
               .where('demand_blocks.unblock_time <= :end_date', end_date: end_date)
               .count
  end

  def blocks_duration_per_stage(projects, start_date, end_date)
    active_blocks_to_projects_and_period(projects, start_date, end_date).closed
                                                                        .joins(:stage)
                                                                        .select('stages.name AS grouped_stage_name, stages.order AS grouped_stage_order, SUM(EXTRACT(EPOCH FROM (demand_blocks.unblock_time - demand_blocks.block_time))) AS time_in_blocked')
                                                                        .group('grouped_stage_name, grouped_stage_order')
                                                                        .order('grouped_stage_order, grouped_stage_name')
                                                                        .map { |group_sum| [group_sum.grouped_stage_name, group_sum.grouped_stage_order, group_sum.time_in_blocked] }
  end
end
