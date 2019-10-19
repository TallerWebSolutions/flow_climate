# frozen_string_literal: true

RSpec.describe DemandInfoDataBuilder, type: :builder do
  describe '#build_data_from_hash_per_week' do
    context 'having info in the hash' do
      let(:info_data_hash) { { Date.new(2019, 1, 27) => 40, Date.new(2019, 2, 10) => 20, Date.new(2019, 3, 3) => 40 } }

      it { expect(described_class.instance.build_data_from_hash_per_week(info_data_hash, Date.new(2019, 1, 20), Date.new(2019, 3, 10))).to eq(Date.new(2019, 1, 20) => 0, Date.new(2019, 1, 27) => 40, Date.new(2019, 2, 3) => 0, Date.new(2019, 2, 10) => 20, Date.new(2019, 2, 17) => 0, Date.new(2019, 2, 24) => 0, Date.new(2019, 3, 3) => 40, Date.new(2019, 3, 10) => 0) }
    end

    context 'empty hash' do
      let(:info_data_hash) { {} }

      it { expect(described_class.instance.build_data_from_hash_per_week(info_data_hash, Date.new(2019, 1, 20), Date.new(2019, 2, 1))).to eq(Date.new(2019, 1, 20) => 0, Date.new(2019, 1, 27) => 0, Date.new(2019, 2, 3) => 0) }
    end

    context 'nil start date' do
      let(:info_data_hash) { {} }

      it { expect(described_class.instance.build_data_from_hash_per_week(info_data_hash, nil, Date.new(2019, 2, 1))).to eq({}) }
    end

    context 'nil end date' do
      let(:info_data_hash) { {} }

      it { expect(described_class.instance.build_data_from_hash_per_week(info_data_hash, Date.new(2019, 1, 20), nil)).to eq({}) }
    end
  end
end
