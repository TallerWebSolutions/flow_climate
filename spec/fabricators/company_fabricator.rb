# frozen_string_literal: true

Fabricator(:company) do
  name { Faker::Company.name }
end
