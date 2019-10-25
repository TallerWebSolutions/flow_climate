# frozen_string_literal: true

Fabricator(:project_broken_wip_log) do
  project

  demands_ids { [1, 2] }
  project_wip { 5 }
end
