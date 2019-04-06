# frozen_string_literal: true

RSpec.describe Stats::StatisticsService, type: :service do
  before { travel_to Time.zone.local(2018, 4, 12, 10, 0, 0) }

  after { travel_back }

  describe '#percentile' do
    let(:empty_population) { [] }

    context 'having no nil value in the population' do
      let(:population) { [2, 4, 10, 56, 5, 4, 4, 89, 2] }

      it 'computes the values' do
        expect(Stats::StatisticsService.instance.percentile(90, empty_population)).to eq 0

        expect(Stats::StatisticsService.instance.percentile(100, population)).to eq 89
        expect(Stats::StatisticsService.instance.percentile(90, population)).to be_within(0.01).of(62.60)
        expect(Stats::StatisticsService.instance.percentile(60, population)).to be_within(0.01).of(4.8)
        expect(Stats::StatisticsService.instance.percentile(40, population)).to be_within(0.01).of(4.0)
      end
    end

    context 'having nil values in the population' do
      let(:population) { [2, 4, nil, 10, 56, 5, nil, 4, 4, 89, 2] }

      it 'computes the values after nil removal' do
        expect(Stats::StatisticsService.instance.percentile(90, empty_population)).to eq 0

        expect(Stats::StatisticsService.instance.percentile(100, population)).to eq 89
        expect(Stats::StatisticsService.instance.percentile(90, population)).to be_within(0.01).of(62.60)
        expect(Stats::StatisticsService.instance.percentile(60, population)).to be_within(0.01).of(4.8)
        expect(Stats::StatisticsService.instance.percentile(40, population)).to be_within(0.01).of(4.0)
      end
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
      context 'with some throughput' do
        subject(:monte_carlo_durations_data) { Stats::StatisticsService.instance.run_montecarlo(30, [10, 15, 12, 15], 100) }

        it 'computes and provides the data' do
          expect(monte_carlo_durations_data.sum).not_to be_zero
        end
      end

      context 'having no throughput' do
        subject(:monte_carlo_durations_data) { Stats::StatisticsService.instance.run_montecarlo(30, [0, 0, 0, 0], 100) }

        it 'returns an empty array' do
          expect(monte_carlo_durations_data).to eq []
        end
      end
    end

    context 'having no data' do
      subject(:monte_carlo_durations_data) { Stats::StatisticsService.instance.run_montecarlo(0, [], 5) }

      it 'returns an empty array' do
        expect(monte_carlo_durations_data).to eq []
      end
    end
  end

  describe '#compute_percentage' do
    context 'when the data count remaining is zero' do
      it { expect(Stats::StatisticsService.instance.compute_percentage(10, 0)).to eq 100.0 }
    end

    context 'when both are zero' do
      it { expect(Stats::StatisticsService.instance.compute_percentage(0, 0)).to eq 0.0 }
    end

    context 'when none is zero' do
      it { expect(Stats::StatisticsService.instance.compute_percentage(10, 40)).to eq 20.0 }
    end
  end

  describe '#mean' do
    it { expect(Stats::StatisticsService.instance.mean([10, 30])).to eq 20 }
  end

  describe '#compute_percentage_variation' do
    context 'not blank values' do
      it { expect(Stats::StatisticsService.instance.compute_percentage_variation(10, 30)).to eq 2.0 }
    end

    context 'initial blank' do
      it { expect(Stats::StatisticsService.instance.compute_percentage_variation(nil, 30)).to eq 0 }
    end

    context 'final blank' do
      it { expect(Stats::StatisticsService.instance.compute_percentage_variation(10, nil)).to eq 0 }
    end
  end

  describe '#standard_deviation' do
    context 'having two or more units in the population' do
      it { expect(Stats::StatisticsService.instance.standard_deviation([10, 30])).to eq 14.142135623730951 }
    end

    context 'having one unit in the population' do
      it { expect(Stats::StatisticsService.instance.standard_deviation([10])).to eq 0 }
    end
  end

  describe '#tail_events_boundary' do
    context 'having two or more units in the population' do
      it { expect(Stats::StatisticsService.instance.tail_events_boundary([10, 30, 20, 5, 100])).to eq 187.66091943344964 }
    end

    context 'having one unit in the population' do
      it { expect(Stats::StatisticsService.instance.tail_events_boundary([10])).to eq 10.0 }
    end

    context 'having nothing in the population' do
      it { expect(Stats::StatisticsService.instance.tail_events_boundary([])).to eq 0 }
    end
  end
end
