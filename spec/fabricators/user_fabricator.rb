# frozen_string_literal: true

Fabricator(:user) do
  first_name { Faker::Name.first_name.gsub(/\W/, '') }
  last_name { Faker::Name.last_name.gsub(/\W/, '') }
  avatar Rack::Test::UploadedFile.new(File.open('spec/fixtures/default_image.png'))
  email { Faker::Internet.email }
  email_address { Faker::Internet.email }
  password 'abc123456'
  password_confirmation 'abc123456'
  email_notifications true
end
