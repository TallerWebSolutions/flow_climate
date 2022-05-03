# frozen_string_literal: true

class DemandTransitionsRepository
  include Singleton

  def summed_transitions_time_grouped_by_stage_demand_for(demands_ids)
    demands_grouped_in_stages = {}

    DemandTransition.kept
                    .joins(:stage)
                    .joins(demand: :project)
                    .select('stages.name AS grouped_stage_name, projects.id AS project_id, demands.external_id AS grouped_external_id, SUM(EXTRACT(EPOCH FROM (demand_transitions.last_time_out - demand_transitions.last_time_in))) AS time_in_stage')
                    .where(demand_id: demands_ids)
                    .group('grouped_stage_name, grouped_external_id, projects.id, stages.order')
                    .order('stages.order, grouped_external_id')
                    .map { |times| demands_grouped_in_stages = build_grouped_hash(demands_grouped_in_stages, times) }

    demands_grouped_in_stages
  end

  def hours_per_stage(projects, stream, stage_level, limit_date)
    DemandTransition.kept
                    .joins(:demand)
                    .joins(:stage)
                    .select('stages.name, stages.order, SUM(EXTRACT(EPOCH FROM (last_time_out - last_time_in))) AS sum_duration')
                    .where(demands: { project_id: projects.map(&:id) })
                    .where('stages.end_point = false AND last_time_in >= :limit_date AND last_time_out IS NOT NULL AND stage_stream = :stage_stream AND stage_level = :stage_level', limit_date: limit_date.beginning_of_day, stage_stream: Stage.stage_streams[stream], stage_level: Stage.stage_levels[stage_level])
                    .group('stages.name, stages.order')
                    .order('stages.order, stages.name')
                    .map { |group_sum| [group_sum.name, group_sum.sum_duration] }
  end

  private

  def build_grouped_hash(demands_grouped_in_stages, times)
    demands_grouped_hash = demands_grouped_in_stages

    demands_grouped_hash[times.grouped_stage_name] = {} if demands_grouped_hash[times.grouped_stage_name].blank?
    demands_grouped_hash[times.grouped_stage_name][:data] = build_data_hash(demands_grouped_hash, times)
    demands_grouped_hash[times.grouped_stage_name][:consolidation] = demands_grouped_hash[times.grouped_stage_name][:data].values.compact.sum

    demands_grouped_hash
  end

  def build_data_hash(demands_grouped_in_stages, times)
    demand_hash = {}
    demand_hash[times.grouped_external_id] = times.time_in_stage

    if demands_grouped_in_stages[times.grouped_stage_name].present?
      demands_grouped_in_stages[times.grouped_stage_name][:data].merge(demand_hash)
    else
      { times.grouped_external_id => demand_hash[times.grouped_external_id] }
    end
  end
end
