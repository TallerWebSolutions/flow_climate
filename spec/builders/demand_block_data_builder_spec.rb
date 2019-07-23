# frozen_string_literal: true

RSpec.describe DemandBlockDataBuilder, type: :builder do
  describe '#build_data_from_hash_per_week' do
    context 'having info in the hash' do
      let(:info_data_hash) { [['bla', 0, 334_422_233.4], ['ble', 1, 322_434.4], ['bli', 2, 977_678_678.4]] }

      it { expect(described_class.instance.build_block_per_stage(info_data_hash)).to eq('bla' => 92_895.06483333332, 'ble' => 89.56511111111112, 'bli' => 271_577.41066666663) }
    end

    context 'empty hash' do
      let(:info_data_hash) { {} }

      it { expect(described_class.instance.build_block_per_stage(info_data_hash)).to eq({}) }
    end
  end

  describe '#build_blocks_count_per_stage' do
    context 'having info in the hash' do
      let(:info_data_hash) { [['bla', 0, 4], ['ble', 1, 5], ['bli', 2, 0]] }

      it { expect(described_class.instance.build_blocks_count_per_stage(info_data_hash)).to eq('bla' => 4, 'ble' => 5, 'bli' => 0) }
    end

    context 'empty hash' do
      let(:info_data_hash) { {} }

      it { expect(described_class.instance.build_blocks_count_per_stage(info_data_hash)).to eq({}) }
    end
  end
end
