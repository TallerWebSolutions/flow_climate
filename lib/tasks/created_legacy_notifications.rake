# frozen_string_literal: true

desc 'Create legacy notifications control'

namespace :demand_transition_notification do
  task create_legacy: :environment do
    Company.all.each { |company| company.demands.each { |demand| demand.demand_transitions.each { |transition| DemandTransitionNotification.where(stage: transition.stage, demand: transition.demand).first_or_create } } }
  end
end
