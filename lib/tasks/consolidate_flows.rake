# frozen_string_literal: true

namespace :statistics do
  desc 'Data cache for projects'
  task consolidate_active_projects: :environment do
    if Time.zone.now.hour.odd?
      Company.all.each do |company|
        company.projects.active.finishing_after(Time.zone.today).each do |project|
          project.remove_outdated_consolidations
          Consolidations::ProjectConsolidationJob.perform_later(project)
        end
      end
    end
  end

  desc 'Data cache for all projects - 6 months'
  task consolidate_all_projects_six_months: :environment do
    Company.all.each do |company|
      company.projects.finishing_after(6.months.ago).each do |project|
        project.remove_outdated_consolidations
        cache_date_arrays = TimeService.instance.days_between_of(project.start_date, Time.zone.today)
        cache_date_arrays.each { |cache_date| Consolidations::ProjectConsolidationJob.perform_later(project, cache_date) }
      end
    end
  end

  desc 'Data cache for active projects - all time'
  task consolidate_active_projects_all_time: :environment do
    Company.all.each do |company|
      company.projects.active.finishing_after(Time.zone.today.beginning_of_year).each do |project|
        project.remove_outdated_consolidations
        cache_date_arrays = TimeService.instance.days_between_of(project.start_date, Time.zone.today)
        cache_date_arrays.each { |cache_date| Consolidations::ProjectConsolidationJob.perform_later(project, cache_date) }
      end
    end
  end

  desc 'Consolidations for contracts'
  task consolidate_contracts: :environment do
    if [10, 15, 20].include?(Time.zone.now.hour)
      Company.all.each do |company|
        company.customers.each do |customer|
          customer.contracts.active(Time.zone.today).each do |contract|
            Consolidations::ContractConsolidationJob.perform_later(contract)
          end
        end
      end
    end
  end

  desc 'Consolidations for customers'
  task consolidate_customers: :environment do
    if [8, 19, 22].include?(Time.zone.now.hour)
      Company.all.each do |company|
        company.customers.select(&:active?).each do |customer|
          Consolidations::CustomerConsolidationJob.perform_later(customer)
        end
      end
    end
  end

  desc 'Consolidations for teams'
  task consolidate_teams: :environment do
    if Time.zone.now.hour.even?
      Company.all.each do |company|
        company.teams.select(&:active?).each do |team|
          Consolidations::TeamConsolidationJob.perform_later(team)
        end
      end
    end
  end

  desc 'Consolidations for replenishing'
  task consolidate_replenishing: :environment do
    Consolidations::ReplenishingConsolidationJob.perform_later
  end
end
