# frozen_string_literal: true

Fabricator(:team_resource) do
  company

  resource_type { [0, 1, 2, 3].sample }
  resource_name { Faker::Internet.name }
end
