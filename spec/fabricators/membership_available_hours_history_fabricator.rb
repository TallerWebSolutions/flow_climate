# frozen_string_literal: true

Fabricator(:membership_available_hours_history, from: 'History::MembershipAvailableHoursHistory') do
  membership

  available_hours 1
  change_date { Time.zone.now }
end
