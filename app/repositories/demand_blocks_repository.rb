# frozen_string_literal: true

class DemandBlocksRepository
  include Singleton

  def closed_blocks_to_projects_and_period_grouped(projects, start_date, end_date)
    active_blocks_to_projects_and_period(projects, start_date, end_date).includes(:demand)
                                                                        .includes(demand: :project)
                                                                        .closed
                                                                        .order('demand_blocks.unblock_time ASC')
                                                                        .group_by { |demand_block| demand_block.demand.project_name }
  end

  def active_blocks_to_projects_and_period(projects, start_date, end_date)
    DemandBlock.kept
               .active
               .joins(demand: :project)
               .where(projects: { id: projects.map(&:id) })
               .where('demand_blocks.block_time >= :start_date AND demand_blocks.block_time <= :end_date', start_date: start_date.beginning_of_day, end_date: end_date.end_of_day)
  end

  def accumulated_blocks_to_date(projects, end_date)
    DemandBlock.kept
               .closed
               .active
               .includes(:demand)
               .joins(demand: :project)
               .where(projects: { id: projects.map(&:id) })
               .where('demand_blocks.unblock_time <= :end_date', end_date: end_date.end_of_day)
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

  def blocks_count_per_stage(projects, start_date, end_date)
    active_blocks_to_projects_and_period(projects, start_date, end_date).closed
                                                                        .joins(:stage)
                                                                        .select('stages.name AS grouped_stage_name, stages.order AS grouped_stage_order, COUNT(1) AS count_block')
                                                                        .group('grouped_stage_name, grouped_stage_order')
                                                                        .order('grouped_stage_order, grouped_stage_name')
                                                                        .map { |block_count| [block_count.grouped_stage_name, block_count.grouped_stage_order, block_count.count_block] }
  end

  def demand_blocks_for_products(products_ids, start_date, end_date)
    DemandBlock.joins(:demand).where(demands: { product_id: products_ids }).where('block_time BETWEEN :start_date AND :end_date', start_date: start_date, end_date: end_date)
  end
end
