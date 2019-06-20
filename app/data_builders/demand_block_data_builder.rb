# frozen_string_literal: true

class DemandBlockDataBuilder
  include Singleton

  def build_block_per_stage(grouped_demand_block_duration_per_stage)
    grouped_stage_hash = {}
    grouped_demand_block_duration_per_stage.each { |grouped_durations| grouped_stage_hash[grouped_durations[0]] = grouped_durations[2] / 1.hour }
    grouped_stage_hash
  end

  def build_blocks_count_per_stage(count_block_per_stage)
    count_block_by_stage_hash = {}
    count_block_per_stage.each { |count_block_by_stage_info| count_block_by_stage_hash[count_block_by_stage_info[0]] = count_block_by_stage_info[2] }
    count_block_by_stage_hash
  end
end
