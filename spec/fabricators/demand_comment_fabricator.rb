# frozen_string_literal: true

Fabricator(:demand_comment) do
  demand
  comment_date 1.day.ago
  comment_text { Faker::Lorem.sentence(2) }
end
