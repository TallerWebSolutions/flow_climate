# frozen_string_literal: true

Fabricator(:team_resource_allocation) do
  team
  team_resource

  start_date { 2.days.ago }
  monthly_payment { 100.0 }
end
