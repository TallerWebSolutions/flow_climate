# frozen_string_literal: true

RSpec.describe FlowClimateImageUploader, type: :image_uploader do
  include CarrierWave::Test::Matchers

  before { FlowClimateImageUploader.enable_processing = true }
  after { FlowClimateImageUploader.enable_processing = false }

  describe '#thumb' do
    let(:uploader) { FlowClimateImageUploader.new(User.new) }
    before { uploader.store!(File.open('spec/fixtures/default_image.png')) }

    it { expect(uploader.thumb).to have_dimensions(50, 28) }
  end

  describe '#extension_whitelist' do
    it { expect(subject.extension_whitelist).to eq %w[jpg jpeg gif png] }
  end

  describe '#store_dir' do
    let(:uploader) { FlowClimateImageUploader.new(User.new(id: 1)) }
    before { uploader.store!(File.open('spec/fixtures/default_image.png')) }
    it { expect(uploader.store_dir).to eq 'uploads/user/1' }
  end

  describe '#public_id' do
    let(:uploader) { FlowClimateImageUploader.new(User.new(id: 1)) }
    before { uploader.store!(File.open('spec/fixtures/default_image.png')) }
    it { expect(uploader.public_id).to eq 'usuarios' }
  end
end
