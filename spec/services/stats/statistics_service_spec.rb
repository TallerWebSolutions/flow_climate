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
      subject(:monte_carlo_simulation_data) { Stats::StatisticsService.instance.run_montecarlo(30, [963_436.0, 460_879.0, 37_221.0, 472_033.0], [10, 15, 12, 15], 100) }
      it 'computes and provides the data' do
        expect(monte_carlo_simulation_data.dates_and_hits_hash.keys.count).to be_within(1).of(6)
        expect(monte_carlo_simulation_data.dates_and_hits_hash.values.count).to be_within(1).of(6)

        expect(monte_carlo_simulation_data.monte_carlo_date_hash.keys.count).to be_within(1).of(6)
        expect(monte_carlo_simulation_data.monte_carlo_date_hash.values.count).to be_within(1).of(6)

        expect(monte_carlo_simulation_data.predicted_dates.size).to be_within(1).of(6)
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

  pending '#compute_percentage'

  describe '#mean' do
    it { expect(Stats::StatisticsService.instance.mean([10, 30])).to eq 20 }
  end

  describe '#standard_deviation' do
    context 'having two or more units in the population' do
      it { expect(Stats::StatisticsService.instance.standard_deviation([10, 30])).to eq 14.142135623730951 }
    end
    context 'having one unit in the population' do
      it { expect(Stats::StatisticsService.instance.standard_deviation([10])).to eq 0 }
    end
  end
end
