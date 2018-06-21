# frozen_string_literal: true

RSpec.describe Highchart::BurnupChartsAdapter, type: :data_object do
  context 'having projects' do
    describe '.initialize' do
      subject(:burnup_data) { Highchart::BurnupChartsAdapter.new([12, 13, 14, 15], [2, 4, 5, 6], [1, 5, 5, 10]) }

      it 'do the math and provides the correct information' do
        expect(burnup_data.burnup_x_axis_period).to eq [12, 13, 14, 15]
        expect(burnup_data.ideal_per_period).to eq [1.5, 3.0, 4.5, 6.0]
        expect(burnup_data.current_per_period).to eq [1, 5, 5, 10]
        expect(burnup_data.scope_per_period).to eq [2, 4, 5, 6]
      end
    end
  end

  context 'having no data' do
    describe '.initialize' do
      subject(:burnup_data) { Highchart::BurnupChartsAdapter.new([], [], []) }

      it 'returns empty arrays' do
        expect(burnup_data.burnup_x_axis_period).to eq []
        expect(burnup_data.ideal_per_period).to eq []
        expect(burnup_data.current_per_period).to eq []
        expect(burnup_data.scope_per_period).to eq []
      end
    end
  end
end
