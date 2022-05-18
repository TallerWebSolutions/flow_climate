# frozen_string_literal: true

class DemandBlocksList < BaseAggregatorObject
  attr_reader :demand_blocks

  def initialize(demand_blocks, total_count, last_page, total_pages)
    @demand_blocks = demand_blocks
    super(total_count, last_page, total_pages)
  end
end
