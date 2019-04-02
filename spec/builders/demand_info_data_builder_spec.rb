# frozen_string_literal: true

RSpec.describe DemandInfoDataBuilder, type: :builder do
  describe '#build_data_from_hash_per_week' do
    context 'having info in the hash' do
      let(:info_data_hash) { { [4.0, 2019.0] => 40, [6.0, 2019.0] => 20, [9.0, 2019.0] => 40 } }

      it { expect(DemandInfoDataBuilder.instance.build_data_from_hash_per_week(info_data_hash, Date.new(2019, 1, 20), Date.new(2019, 3, 10))).to eq(Date.new(2019, 1, 14) => 0, Date.new(2019, 1, 21) => 40, Date.new(2019, 1, 28) => 0, Date.new(2019, 2, 4) => 20, Date.new(2019, 2, 11) => 0, Date.new(2019, 2, 18) => 0, Date.new(2019, 2, 25) => 40, Date.new(2019, 3, 4) => 0) }
    end

    context 'empty hash' do
      let(:info_data_hash) { {} }

      it { expect(DemandInfoDataBuilder.instance.build_data_from_hash_per_week(info_data_hash, Date.new(2019, 1, 20), Date.new(2019, 2, 1))).to eq(Date.new(2019, 1, 14) => 0, Date.new(2019, 1, 21) => 0, Date.new(2019, 1, 28) => 0) }
    end
  end
end
