# frozen_string_literal: true

Fabricator(:customer) do
  company
  name { Faker::Company.name }
end
