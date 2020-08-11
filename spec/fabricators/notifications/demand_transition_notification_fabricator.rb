# frozen-string-literal: true

Fabricator(:demand_transition_notification, from: 'Notifications::DemandTransitionNotification') do
  stage
  demand
end
