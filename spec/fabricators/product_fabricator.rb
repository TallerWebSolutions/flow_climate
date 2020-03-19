# frozen_string_literal: true

Fabricator(:product) do
  customer
  name { Faker::Name.unique.name.gsub(/\W/, '') }
end
