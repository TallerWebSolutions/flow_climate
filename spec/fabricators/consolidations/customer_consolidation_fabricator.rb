# frozen_string_literal: true

Fabricator(:customer_consolidation, from: 'Consolidations::CustomerConsolidation') do
  customer

  consolidation_date { Time.zone.today }

  consumed_hours { 10 }
  average_consumed_hours_in_month { 5 }
end
