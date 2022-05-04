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
