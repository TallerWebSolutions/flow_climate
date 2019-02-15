# frozen_string_literal: true

class FlowClimateImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

  version :thumb do
    process resize_to_fit: [50, 50]
  end

  def extension_whitelist
    %w[jpg jpeg gif png]
  end
end
