# frozen_string_literal: true

RSpec.describe ScatterData, type: :data_object do
  describe '.initialize' do
    context 'with data' do
      it 'builds the data object with the times and the percentiles' do
        data = described_class.new([3, 2, 1, 5, 2, 7, 10, 15], [2, 7, 10, 23, 100, 54, 13, 8])

        expect(data.completion_times).to eq [3, 2, 1, 5, 2, 7, 10, 15]
        expect(data.items_ids).to eq [2, 7, 10, 23, 100, 54, 13, 8]
        expect(data.completion_time_p95).to eq 13.249999999999996
        expect(data.completion_time_p80).to eq 8.8
        expect(data.completion_time_p65).to eq 6.1
      end
    end

    context 'without data' do
      it 'builds the an empty data object' do
        data = described_class.new([], [])

        expect(data.completion_times).to eq []
        expect(data.items_ids).to eq []
        expect(data.completion_time_p95).to eq 0
        expect(data.completion_time_p80).to eq 0
        expect(data.completion_time_p65).to eq 0
      end
    end
  end
end
