# frozen_string_literal: true

Fabricator(:demand_data_processment) do
  user
  user_plan

  project_key { Faker::Lorem.characters }

  downloaded_content { Faker::Lorem.paragraph }
end
