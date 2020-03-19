# frozen_string_literal: true

Fabricator(:customer) do
  company
  name { Faker::Name.unique.name.gsub(/\W/, '') }
end
