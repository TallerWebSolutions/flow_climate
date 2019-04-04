# frozen_string_literal: true

class DemandBlockDataBuilder
  include Singleton

  def build_block_per_stage(grouped_demand_block_duration_per_stage)
    grouped_stage_hash = {}
    grouped_demand_block_duration_per_stage.each do |grouped_durations|
      grouped_stage_hash[grouped_durations[0]] = grouped_durations[2] / 1.hour
    end
    grouped_stage_hash
  end
end
