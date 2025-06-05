# frozen_string_literal: true

Fabricator(:company_working_hours_config) do
  company
  hours_per_day { 7 }
  start_date { Time.zone.today }
  end_date { nil }
  active { true }
end
