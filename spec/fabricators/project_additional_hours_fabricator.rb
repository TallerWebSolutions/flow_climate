# frozen_string_literal: true

Fabricator(:project_additional_hour) do
  project
  event_date { Time.zone.today }
  hours_type { 0 }
  hours { 10 }
  obs { 'bla' }
end
