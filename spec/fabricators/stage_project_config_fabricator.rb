# frozen_string_literal: true

Fabricator(:stage_project_config) do
  project
  stage
  compute_effort true
  stage_percentage { [10, 80, 100].sample }
  management_percentage { [20, 30, 40].sample }
  pairing_percentage { [10, 50, 100].sample }
end
