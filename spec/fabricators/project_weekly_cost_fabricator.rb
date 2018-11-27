# frozen_string_literal: true

Fabricator(:project_weekly_cost) do
  project
  date_beggining_of_week { Time.zone.today }
  monthly_cost_value '9.99'
end
