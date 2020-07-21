# frozen_string_literal: true

desc 'Create legacy notifications control'

namespace :demand_transition_notification do
  task create_legacy: :environment do
    DemandTransition.all.each { |transition| DemandTransitionNotification.create(stage: transition.stage, demand: transition.demand) }
  end
end
