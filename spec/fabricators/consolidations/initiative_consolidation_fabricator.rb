# frozen_string_literal: true

Fabricator(:initiative_consolidation, from: 'Consolidations::InitiativeConsolidation') do
  initiative
  consolidation_date { Time.zone.today }
end
