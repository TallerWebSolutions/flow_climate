# frozen_string_literal: true

RSpec.describe Stats::StatisticsService, type: :service do
  before { travel_to Time.zone.local(2018, 4, 12, 10, 0, 0) }
  after { travel_back }

  describe '#percentile' do
    let(:empty_population) { [] }
    let(:population) { [2, 4, 10, 56, 5, 4, 4, 89, 2] }

    it 'computes the values' do
      expect(Stats::StatisticsService.instance.percentile(90, empty_population)).to eq 0

      expect(Stats::StatisticsService.instance.percentile(100, population)).to eq 89
      expect(Stats::StatisticsService.instance.percentile(90, population)).to be_within(0.01).of(62.60)
      expect(Stats::StatisticsService.instance.percentile(60, population)).to be_within(0.01).of(4.8)
      expect(Stats::StatisticsService.instance.percentile(40, population)).to be_within(0.01).of(4.0)
    end
  end

  describe '#leadtime_histogram_hash' do
    it { expect(Stats::StatisticsService.instance.leadtime_histogram_hash([1.23, 2.34, 4.2, 3.5])).to eq(1.9725000000000001 => 2.0, 3.4575 => 2.0) }
  end

  describe '#throughput_histogram_hash' do
    it { expect(Stats::StatisticsService.instance.throughput_histogram_hash([10, 20, 12, 15, 7, 2, 18])).to eq(5.0 => 2.0, 11.0 => 2.0, 17.0 => 3.0) }
  end

  describe '#run_montecarlo' do
    context 'having data' do
      subject(:monte_carlo_simulation_data) { Stats::StatisticsService.instance.run_montecarlo(30, [1.23, 2.34, 4.2, 3.5, 1.15, 2.40, 5.10, 2.20, 3.45, 4.1], [10, 15, 12, 15, 7, 10, 18, 11, 14, 13], 100) }
      it 'computes and provides the data' do
        expect(monte_carlo_simulation_data.dates_and_hits_hash.keys[0]).to be_within(5.days).of(1_523_502_000)
        expect(monte_carlo_simulation_data.dates_and_hits_hash.values[0]).to be_within(30).of(100)
        expect(monte_carlo_simulation_data.monte_carlo_date_hash.keys[0].to_time.to_i).to be_within(6.days).of(1_523_847_600)
        expect(monte_carlo_simulation_data.monte_carlo_date_hash.values[0].to_f).to eq 1
        expect(monte_carlo_simulation_data.predicted_dates.size).to be >= 1
      end
    end
    context 'having no data' do
      subject(:monte_carlo_simulation_data) { Stats::StatisticsService.instance.run_montecarlo(0, [], [], 5) }
      it 'computes and provides the data' do
        expect(monte_carlo_simulation_data.dates_and_hits_hash).to eq(1_523_502_000 => 5)
        expect(monte_carlo_simulation_data.monte_carlo_date_hash).to eq(Date.new(2018, 4, 12) => 1)
        expect(monte_carlo_simulation_data.predicted_dates).to eq [[1_523_502_000, 5]]
      end
    end
  end
end
