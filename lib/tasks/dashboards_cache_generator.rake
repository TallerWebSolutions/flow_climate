# frozen_string_literal: true

namespace :dashboards_cache do
  desc 'Generates operations cache - all time'
  task generate_operations_dashboard_cache_all_time: :environment do
    TeamMember.all.each do |member|
      last_delivery = member.last_delivery
      first_pull = member.first_assignment
      last_pull = member.last_assignment

      start_date = [member.start_date, member.created_at.to_date, first_pull.start_time].compact.max
      end_date = [last_delivery.end_date, member.end_date, last_pull.start_time].compact.max

      next if last_pull.blank? || last_pull.start_time < 3.months.ago

      Dashboards::OperationsDashboardCacheJob.perform_later(member, start_date, end_date)
    end
  end

  desc 'Generates operations cache - day'
  task generate_operations_dashboard_cache: :environment do
    TeamMember.active.each do |member|
      last_pull = member.last_assignment
      next if last_pull.blank? || last_pull.start_time < 3.months.ago

      Dashboards::OperationsDashboardCacheJob.perform_later(member, Time.zone.today, Time.zone.today)
    end
  end
end
