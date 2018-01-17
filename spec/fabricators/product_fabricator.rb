# frozen_string_literal: true

Fabricator(:product) do
  customer
  name { Faker::Company.name }
end
