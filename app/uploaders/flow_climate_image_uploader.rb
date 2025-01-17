# frozen_string_literal: true

class FlowClimateImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Incluir Cloudinary apenas fora do ambiente de teste
  include Cloudinary::CarrierWave unless Rails.env.test?

  # Processamento de imagem, exceto em ambiente de teste
  process convert: 'png' unless Rails.env.test?
  process tags: ['post_picture'] unless Rails.env.test?

  # Armazenamento local para o ambiente de teste
  storage :file if Rails.env.test?

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

  def extension_allowlist
    %w[jpg jpeg gif png]
  end

  def public_id
    I18n.transliterate("#{model.model_name.human.downcase}_#{Rails.env}_#{model.id}")
  end
end
