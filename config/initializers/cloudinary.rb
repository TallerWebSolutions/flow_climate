# frozen_string_literal: true

Cloudinary.config do |config|
  config.cloud_name = Figaro.env.cloudinary_cloud_name
  config.api_key = Figaro.env.cloudinary_api_key
  config.api_secret = Figaro.env.cloudinary_api_secret
end
