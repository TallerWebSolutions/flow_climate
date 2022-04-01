# frozen_string_literal: true

Fabricator(:company) do
  abbreviation { Faker::Alphanumeric.letterify('??????') }
  name { Faker::Company.name.gsub(/\W/, '') }
  active { true }
end
