# frozen_string_literal: true

Fabricator(:demand_comment) do
  demand
  team_member
  comment_date 1.day.ago
  comment_text { Faker::Lorem.sentence(word_count: 2) }
end
