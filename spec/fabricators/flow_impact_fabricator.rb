# frozen_string_literal: true

Fabricator(:flow_impact) do
  project
  demand

  impact_type { [0, 1, 2].sample }
  impact_description { Faker::Lorem.sentences(1) }

  start_date { 1.day.ago }
end
