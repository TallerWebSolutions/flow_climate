# frozen_string_literal: true

module Slack
  class DemandSlackNotificationsJob < ApplicationJob
    include Rails.application.routes.url_helpers

    def perform(team)
      team.demands.each do |demand|
        process_blocks(demand)
        process_transitions(demand)
        process_assignments(demand)
      end
    end

    private

    def process_transitions(demand)
      demand.demand_transitions.each do |transition|
        next if transition.transition_notified?
        Slack::SlackNotificationService.instance.notify_demand_state_changed(transition.stage, demand, transition)
      end
    end

    def process_assignments(demand)
      assignments_invalid = demand.item_assignments.select { |assignment| assignment.valid? == false }
      
      assignments_invalid.each do |assignment_invalid|
        DemandEffort.safe_destroy_each(assignment_invalid.demand_efforts)
        
        begin
          assignment_invalid.destroy
        rescue ActiveRecord::StaleObjectError
          Rails.logger.info("ItemAssignment #{assignment_invalid.id} already destroyed by another process - skipping")
        rescue ActiveRecord::RecordNotFound
          Rails.logger.info("ItemAssignment #{assignment_invalid.id} already deleted - skipping")
        end
      end

      demand.item_assignments.reload.where(assignment_notified: false).each do |assignment|
        demand_url = company_demand_url(demand.company, demand)
        Slack::SlackNotificationService.instance.notify_item_assigned(assignment, demand_url)
        
        begin
          ItemAssignment.transaction { assignment.update(assignment_notified: true) }
        rescue ActiveRecord::StaleObjectError
          Rails.logger.info("ItemAssignment #{assignment.id} was updated by another process - skipping notification update")
        end
      end
    end

    def process_blocks(demand)
      demand.demand_blocks.each do |block|
        return if block.demand_block_notifications.unblocked.present?

        demand = block.demand
        demand_url = company_demand_url(demand.company, demand)
        edit_block_url = edit_company_project_demand_demand_block_url(demand.company, demand.project, demand, block)

        Slack::SlackNotificationService.instance.notify_item_blocked(block, demand_url, edit_block_url) if block.demand_block_notifications.blank?
        Slack::SlackNotificationService.instance.notify_item_blocked(block, demand_url, edit_block_url, 'unblocked') if block.unblock_time.present? && block.demand_block_notifications.unblocked.blank?
      end
    end
  end
end
