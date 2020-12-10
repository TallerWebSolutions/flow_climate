# frozen_string_literal: true

class BaseFlowAdapter
  private

  def persist_block!(demand, author, created_at, demand_url)
    demand_block = demand.demand_blocks.where(block_time: created_at).first_or_initialize
    demand_block.update(blocker: author, block_reason: read_reason(demand, created_at), unblock_time: nil, unblocker: nil)

    edit_block_url = edit_company_project_demand_demand_block_url(demand.company, demand.project, demand, demand_block)

    Slack::SlackNotificationService.instance.notify_item_blocked(demand_block, demand_url, edit_block_url)
  end

  def read_reason(demand, created)
    created_date = Time.zone.iso8601(created)
    demand_comments = demand.demand_comments.where(comment_date: (created_date.beginning_of_minute..created_date.end_of_minute))
    block_reason = demand_comments.find { |comment| comment.comment_text.downcase.include?('(flag)') }&.comment_text || ''
    block_reason.delete_prefix("(flag) Sinalizador adicionado\n\n").delete_prefix("(flag) Flag added\n\n")
  end

  def persist_unblock!(demand, author, unblock_time, demand_url)
    demand_block = demand.demand_blocks.open.first
    return if demand_block.blank?

    demand_block.update(unblocker: author, unblock_time: unblock_time)

    edit_block_url = edit_company_project_demand_demand_block_url(demand.company, demand.project, demand, demand_block)

    Slack::SlackNotificationService.instance.notify_item_blocked(demand_block, demand_url, edit_block_url, 'unblocked')
  end
end
