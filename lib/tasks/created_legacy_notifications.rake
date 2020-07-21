# frozen_string_literal: true

desc 'Create legacy notifications control'

namespace :item_assignment_notification do
  task create_legacy: :environment do
    Company.all.each { |company| company.projects.each { |project| project.demands.each { |demand| demand.item_assignments.each { |assignment| ItemAssignmentNotification.where(item_assignment: assignment).first_or_create } } } }
  end
end
