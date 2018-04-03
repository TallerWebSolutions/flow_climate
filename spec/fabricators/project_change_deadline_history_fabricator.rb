# frozen_string_literal: true

Fabricator(:project_change_deadline_history) do
  project
  user
  previous_date { Time.zone.today }
  new_date { Time.zone.yesterday }
end
