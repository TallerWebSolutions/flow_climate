# frozen_string_literal: true

Fabricator(:demand_data_processment) do
  user
  user_plan

  project_key { Faker::Lorem.characters(4) }

  downloaded_content { Faker::Lorem.paragraph(3) }
end
