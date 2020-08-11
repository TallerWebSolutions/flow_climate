# frozen_string_literal: true

desc 'Create legacy notifications control'

namespace :demand_block_notification do
  task create_legacy: :environment do
    Company.all.each do |company|
      company.projects.each do |project|
        project.demands.each do |demand|
          demand.demand_blocks.each do |block|
            Notifications::DemandBlockNotification.where(demand_block: block, block_state: 'blocked').first_or_create
            Notifications::DemandBlockNotification.where(demand_block: block, block_state: 'unblocked').first_or_create if block.unblock_time.present?
          end
        end
      end
    end
  end
end
