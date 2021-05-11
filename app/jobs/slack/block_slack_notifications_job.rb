# frozen_string_literal: true

module Slack
  class BlockSlackNotificationsJob < ApplicationJob
    include Rails.application.routes.url_helpers

    def perform(team)
      team.demand_blocks.each do |block|
        return if block.demand_block_notifications.unblocked.present?

        demand = block.demand
        demand_url = company_demand_url(demand.company, demand)
        edit_block_url = edit_company_project_demand_demand_block_url(demand.company, demand.project, demand, block)
        if block.demand_block_notifications.blank?
          Slack::SlackNotificationService.instance.notify_item_blocked(block, demand_url, edit_block_url)
          Slack::SlackNotificationService.instance.notify_item_blocked(block, demand_url, edit_block_url, 'unblocked') if block.unblock_time.present?
        else
          Slack::SlackNotificationService.instance.notify_item_blocked(block, demand_url, edit_block_url, 'unblocked')
        end
      end
    end
  end
end
