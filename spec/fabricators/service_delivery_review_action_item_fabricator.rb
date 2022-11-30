# frozen_string_literal: true

Fabricator(:service_delivery_review_action_item) do
  service_delivery_review
  membership

  description { Faker::Movie.quote }
end
