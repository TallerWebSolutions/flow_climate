# frozen_string_literal: true

Fabricator(:project_consolidation, from: 'Consolidations::ProjectConsolidation') do
  project
  consolidation_date { Time.zone.today }
  demands_finished_ids { [1, 2, 5, 7] }
  demands_ids { [1, 2, 5, 7, 9, 10, 112] }
  wip_limit { 10 }
end
