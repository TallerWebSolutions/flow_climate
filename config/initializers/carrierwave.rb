# frozen_string_literal: true

CarrierWave.configure do |config|
  config.root = Rails.root.join('tmp')
  config.cache_dir = 'carrierwave'
  config.enable_processing = true

  # Excluir Cloudinary no ambiente de teste
  config.storage = :file if Rails.env.test?
end
