# frozen_string_literal: true

Fabricator(:contract) do
  customer
  product

  start_date { Time.zone.yesterday }
  total_value { 1000 }
  total_hours { 35 }
  hours_per_demand { 30 }
end
