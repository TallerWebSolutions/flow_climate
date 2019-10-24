# frozen_string_literal: true

desc 'Consolidations for flow and projects'

namespace :statistics do
  task consolidate_weekly: :environment do
    Company.all.each do |company|
      company.projects.active.finishing_after(Time.zone.today).each { |project| ProjectConsolidationJob.perform_later(project) }
    end
  end
end
