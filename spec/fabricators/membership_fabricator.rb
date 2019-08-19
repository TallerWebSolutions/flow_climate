# frozen_string_literal: true

Fabricator(:membership) do
  team
  team_member

  start_date { 2.days.ago }
  end_date { Time.zone.today }

  hours_per_month { [100, 200, 300, 400, 203, 123, 44, 221, 453].sample }
end
