# frozen_string_literal: true

class BaseFlowAdapter
  private

  def persist_block!(demand, author, created_at)
    new_id = (demand.demand_blocks.map(&:demand_block_id).max || 0) + 1
    demand_block = demand.demand_blocks.where(demand_block_id: new_id, block_time: created_at).first_or_initialize
    demand_block.update(blocker_username: author)
  end

  def persist_unblock!(demand, author, unblock_time)
    max_blocked_id = demand.demand_blocks.open.map(&:demand_block_id).max
    demand_block = demand.demand_blocks.open.where(demand: demand, demand_block_id: max_blocked_id).first
    return if demand_block.blank?

    demand_block.update(unblocker_username: author, unblock_time: unblock_time)
  end
end
