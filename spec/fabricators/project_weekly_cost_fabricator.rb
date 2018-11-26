# frozen_string_literal: true

Fabricator(:project_weekly_cost) do
  id                     1
  project_id             1
  date_beggining_of_week '2018-11-19'
  monthly_cost_value     '9.99'
  created_at             '2018-11-19 15:32:03'
  updated_at             '2018-11-19 15:32:03'
end
