# frozen-string-literal: true

Fabricator(:contract_estimation_change_history) do
  contract
  created_date { Time.zone.now }
  hours_per_demand { 30 }
end
