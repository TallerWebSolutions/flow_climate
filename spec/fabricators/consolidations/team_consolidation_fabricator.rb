# frozen_string_literal: true

Fabricator(:team_consolidation, from: 'Consolidations::TeamConsolidation') do
  team
  consolidation_date { Time.zone.today }
end
