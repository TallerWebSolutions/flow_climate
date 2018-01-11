# frozen_string_literal: true

Fabricator(:user) do
  first_name { Faker::Name.first_name }
  last_name { Faker::Name.last_name }
  email { Faker::Internet.email }
  password 'abc123456'
  password_confirmation 'abc123456'
end
