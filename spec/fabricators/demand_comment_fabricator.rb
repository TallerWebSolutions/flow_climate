# frozen_string_literal: true

Fabricator(:demand_comment) do
  demand
  commitment_date 1.day.ago
  commitment_text { Faker::Lorem.sentence(2) }
end
