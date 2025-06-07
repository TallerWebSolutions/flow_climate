# frozen_string_literal: true

Fabricator(:company_working_hours_config) do
  company
  hours_per_day { 6 }
  start_date { Time.zone.today - 20.years }
  end_date { nil }
end
