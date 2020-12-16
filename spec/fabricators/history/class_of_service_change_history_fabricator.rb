# frozen_string_literal: true

Fabricator(:class_of_service_change_history, from: 'History::ClassOfServiceChangeHistory') do
  demand

  change_date { 1.day.ago }
  from_class_of_service { 0 }
  to_class_of_service { 1 }
end
