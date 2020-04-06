# frozen_string_literal: true

Fabricator(:risk_review_action_item) do
  risk_review
  membership

  created_date { 1.day.ago }
  description { Faker::Lorem.sentences(2) }

  deadline { 1.month.from_now }
end
