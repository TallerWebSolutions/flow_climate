# frozen_string_literal: true

Fabricator(:product) do
  company
  customer
  name { Faker::Name.unique.name }
end
