# frozen_string_literal: true

Fabricator(:team) do
  company
  name { Faker::Name.unique.name.gsub(/\W/, '') }
end
