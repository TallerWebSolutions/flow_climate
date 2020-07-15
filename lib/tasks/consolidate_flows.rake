# frozen_string_literal: true

namespace :statistics do
  desc 'Consolidations for projects'
  task consolidate_weekly: :environment do
    Company.all.each do |company|
      company.projects.active.finishing_after(Time.zone.today).each { |project| Consolidations::ProjectConsolidationJob.perform_later(project) }
    end
  end

  desc 'Consolidations for contracts'
  task consolidate_contracts: :environment do
    Company.all.each do |company|
      company.customers.each do |customer|
        customer.contracts.active(Time.zone.today).each do |contract|
          Consolidations::ContractConsolidationJob.perform_later(contract)
        end
      end
    end
  end
end
