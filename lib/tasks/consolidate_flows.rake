# frozen_string_literal: true

namespace :statistics do
  desc 'Data cache for projects'
  task consolidate_active_projects: :environment do
    if Time.zone.now.hour.odd?
      Company.find_each do |company|
        company.projects.active.finishing_after(Time.zone.today).each do |project|
          project.remove_outdated_consolidations
          Consolidations::ProjectConsolidationJob.perform_later(project)
        end
      end
    end
  end

  desc 'Consolidations for contracts'
  task consolidate_contracts: :environment do
    Company.find_each do |company|
      company.customers.each do |customer|
        customer.contracts.active(Time.zone.today).each do |contract|
          Consolidations::ContractConsolidationJob.perform_later(contract)
        end
      end
    end
  end

  desc 'Consolidations for customers'
  task consolidate_customers: :environment do
    Company.find_each do |company|
      company.customers.select(&:active?).each do |customer|
        (12.months.ago.to_date..Time.zone.today).to_a.each do |date|
          Consolidations::CustomerConsolidationJob.perform_later(customer, date)
        end
      end
    end
  end

  desc 'Consolidations for teams'
  task consolidate_teams: :environment do
    if Time.zone.now.hour.even?
      Company.find_each do |company|
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
