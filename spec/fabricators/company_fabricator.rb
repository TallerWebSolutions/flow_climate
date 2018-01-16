# frozen_string_literal: true

Fabricator(:company) do
  abbreviation { Faker::Company.buzzword }
  name { Faker::Company.name }
end
