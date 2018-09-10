# frozen_string_literal: true

class BaseFlowAdapter
  private

  def persist_block!(demand, author, created_at, demand_block_id, block_reason)
    demand_block = demand.demand_blocks.where(demand_block_id: demand_block_id, block_time: created_at).first_or_initialize
    demand_block.update(blocker_username: author, block_time: created_at, block_reason: block_reason.strip)
  end

  def persist_unblock!(demand, author, unblock_time, demand_block_id, unblock_reason)
    demand_block = demand.demand_blocks.open.where(demand: demand, demand_block_id: demand_block_id).first
    return if demand_block.blank?

    demand_block.update(unblocker_username: author, unblock_time: unblock_time, unblock_reason: unblock_reason.strip)
  end
end
