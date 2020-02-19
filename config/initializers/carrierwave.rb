# frozen_string_literal: true

CarrierWave.configure do |config|
  config.root = Rails.root.join('tmp') # adding these...
  config.cache_dir = 'carrierwave' # ...two lines
  config.cache_storage = :file

  # config.fog_credentials = {
  #   provider: 'AWS', # required
  #   aws_access_key_id: 'key', # required
  #   aws_secret_access_key: 'secret', # required
  #   region: 'eu-west-1', # optional, defaults to 'us-east-1'
  #   host: 's3.example.com', # optional, defaults to nil
  #   endpoint: 'https://s3.example.com:8080' # optional, defaults to nil
  # }
  #
  # config.fog_directory  = 'directory'                             # required
  # config.fog_public     = false                                   # optional, defaults to true
  # config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' } # optional, defaults to {}
end
