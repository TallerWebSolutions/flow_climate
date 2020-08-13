# frozen_string_literal: true

Fabricator(:contract_consolidation, from: 'Consolidations::ContractConsolidation') do
  contract

  consolidation_date { Time.zone.today }
  operational_risk_value { Time.zone.today }
end
