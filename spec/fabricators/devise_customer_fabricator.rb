# frozen_string_literal: true

Fabricator(:devise_customer) do
  first_name { Faker::Name.first_name.gsub(/\W/, '') }
  last_name { Faker::Name.last_name.gsub(/\W/, '') }
  email { Faker::Internet.email }
  password 'abc123456'
  password_confirmation 'abc123456'
end
