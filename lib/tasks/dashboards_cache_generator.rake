# frozen_string_literal: true

namespace :dashboards_cache do
  desc 'Generates operations cache - all time'
  task generate_operations_dashboard_cache_all_time: :environment do
    TeamMember.all.each do |member|
      next if member.id != 602

      first_delivery = member.demands.undiscarded.finished_until_date(Time.zone.now).order(:end_date).first

      start_date = member.start_date || member.created_at.to_date
      dashboard_start_date = first_delivery&.end_date || start_date
      Dashboards::OperationsDashboardCacheJob.perform_later(member, dashboard_start_date, Time.zone.today)
    end
  end

  desc 'Generates operations cache - day'
  task generate_operations_dashboard_cache: :environment do
    TeamMember.active.each do |member|
      Dashboards::OperationsDashboardCacheJob.perform_now(member, Time.zone.today, Time.zone.today)
    end
  end
end
