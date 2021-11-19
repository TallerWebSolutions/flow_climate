# frozen_string_literal: true

Fabricator(:flow_event) do
  company
  project

  event_type { [0, 1, 2].sample }
  event_size { [0, 1, 2].sample }
  event_description { Faker::Lorem.sentences }

  event_date { 1.day.ago }
end
