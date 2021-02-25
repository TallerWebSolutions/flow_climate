# frozen_string_literal: true

class FlowClimateImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  include Cloudinary::CarrierWave unless Rails.env.test?
  process convert: 'png' unless Rails.env.test?
  process tags: ['post_picture'] unless Rails.env.test?

  storage :file if Rails.env.test?

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

  version :standard do
    process resize_to_fill: [100, 150, :north]
  end

  version :thumb do
    process resize_to_fit: [50, 50]
  end

  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  def public_id
    I18n.transliterate("#{model.model_name.human.downcase}_#{Rails.env}_#{model.id}")
  end
end
