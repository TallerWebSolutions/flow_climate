# frozen_string_literal: true

RSpec.describe Stats::StatisticsService, type: :service do
  before { travel_to Time.zone.local(2018, 4, 12, 10, 0, 0) }

  describe '#percentile' do
    let(:empty_population) { [] }

    context 'with no nil value in the population' do
      let(:population) { [2, 4, 10, 56, 5, 4, 4, 89, 2] }

      it 'computes the values' do
        expect(described_class.instance.percentile(90, empty_population)).to eq 0

        expect(described_class.instance.percentile(100, population)).to eq 89
        expect(described_class.instance.percentile(90, population)).to be_within(0.01).of(62.60)
        expect(described_class.instance.percentile(60, population)).to be_within(0.01).of(4.8)
        expect(described_class.instance.percentile(40, population)).to be_within(0.01).of(4.0)
      end
    end

    context 'with nil values in the population' do
      let(:population) { [2, 4, nil, 10, 56, 5, nil, 4, 4, 89, 2] }

      it 'computes the values after nil removal' do
        expect(described_class.instance.percentile(90, empty_population)).to eq 0

        expect(described_class.instance.percentile(100, population)).to eq 89
        expect(described_class.instance.percentile(90, population)).to be_within(0.01).of(62.60)
        expect(described_class.instance.percentile(60, population)).to be_within(0.01).of(4.8)
        expect(described_class.instance.percentile(40, population)).to be_within(0.01).of(4.0)
      end
    end
  end

  describe '#percentile_for_lead_time' do
    let(:empty_population) { [] }

    context 'with no nil value in the population' do
      it 'computes the values' do
        population = [2, 4, 10, 56, 5, 4, 4, 89, 2]

        expect(described_class.instance.percentile(4, empty_population)).to eq 0

        expect(described_class.instance.percentile_for_lead_time(0, population)).to eq 0
        expect(described_class.instance.percentile_for_lead_time(93, population)).to eq 1
        expect(described_class.instance.percentile_for_lead_time(5, population)).to eq 0.5555555555555556
      end
    end

    context 'with nil values in the population' do
      let(:population) { [2, 4, nil, 10, 56, 5, nil, 4, 4, 89, 2] }

      it 'computes the values after nil removal' do
        expect(described_class.instance.percentile_for_lead_time(0, population)).to eq 0
        expect(described_class.instance.percentile_for_lead_time(93, population)).to eq 1
        expect(described_class.instance.percentile_for_lead_time(5, population)).to eq 0.5555555555555556
      end
    end
  end

  describe '#leadtime_histogram_hash' do
    it { expect(described_class.instance.leadtime_histogram_hash([1.23, 2.34, 4.2, 3.5])).to eq(1.9725000000000001 => 2.0, 3.4575 => 2.0) }
  end

  describe '#completiontime_histogram_hash' do
    it { expect(described_class.instance.completiontime_histogram_hash([2.5, 7.64, 9.1, 5.2])).to eq(4.15 => 2.0, 7.449999999999999 => 2.0) }
  end

  describe '#throughput_histogram_hash' do
    it { expect(described_class.instance.throughput_histogram_hash([10, 20, 12, 15, 7, 2, 18])).to eq(5.0 => 2.0, 11.0 => 2.0, 17.0 => 3.0) }
  end

  describe '#run_montecarlo' do
    context 'with data' do
      context 'with some throughput' do
        subject(:monte_carlo_durations_data) { described_class.instance.run_montecarlo(30, [10, 15, 12, 15], 100) }

        it 'computes and provides the data' do
          expect(monte_carlo_durations_data.sum).not_to be_zero
        end
      end

      context 'with no throughput' do
        subject(:monte_carlo_durations_data) { described_class.instance.run_montecarlo(30, [0, 0, 0, 0], 100) }

        it 'returns an empty array' do
          expect(monte_carlo_durations_data).to eq []
        end
      end
    end

    context 'with no data' do
      subject(:monte_carlo_durations_data) { described_class.instance.run_montecarlo(0, [], 5) }

      it 'returns an empty array' do
        expect(monte_carlo_durations_data).to eq []
      end
    end
  end

  describe '#compute_percentage' do
    context 'when the data count remaining is zero' do
      it { expect(described_class.instance.compute_percentage(10, 0)).to eq 100.0 }
    end

    context 'when both are zero' do
      it { expect(described_class.instance.compute_percentage(0, 0)).to eq 0.0 }
    end

    context 'when none is zero' do
      it { expect(described_class.instance.compute_percentage(10, 40)).to eq 20.0 }
    end
  end

  describe '#mean' do
    it { expect(described_class.instance.mean([10, 30])).to eq 20 }
  end

  describe '#compute_percentage_variation' do
    context 'not blank values' do
      it { expect(described_class.instance.compute_percentage_variation(10, 30)).to eq 2.0 }
    end

    context 'initial blank' do
      it { expect(described_class.instance.compute_percentage_variation(nil, 30)).to eq 0 }
    end

    context 'final blank' do
      it { expect(described_class.instance.compute_percentage_variation(10, nil)).to eq 0 }
    end
  end

  describe '#standard_deviation' do
    context 'with two or more units in the population' do
      it { expect(described_class.instance.standard_deviation([10, 30])).to eq 14.142135623730951 }
    end

    context 'with one unit in the population' do
      it { expect(described_class.instance.standard_deviation([10])).to eq 0 }
    end
  end

  describe '#mode' do
    context 'with data' do
      it { expect(described_class.instance.mode([10, 30, 10])).to eq 10 }
    end

    context 'with no data' do
      it { expect(described_class.instance.mode([])).to be_nil }
    end
  end

  describe '#population_average' do
    context 'with data' do
      it { expect(described_class.instance.population_average([10, 30, 10, 18, 21, 15])).to eq 17.333333333333332 }
      it { expect(described_class.instance.population_average([10, 30, 10, 18, 21, 15], 3)).to eq 18 }
    end

    context 'with no data' do
      it { expect(described_class.instance.population_average([])).to eq 0 }
    end
  end

  describe '#tail_events_boundary' do
    context 'with two or more units in the population' do
      it { expect(described_class.instance.tail_events_boundary([10, 30, 20, 5, 100])).to eq 187.66091943344964 }
    end

    context 'with one unit in the population' do
      it { expect(described_class.instance.tail_events_boundary([10])).to eq 10.0 }
    end

    context 'with nothing in the population' do
      it { expect(described_class.instance.tail_events_boundary([])).to eq 0 }
    end
  end

  describe '#compute_odds_to_deadline' do
    context 'no montecarlo data' do
      it { expect(described_class.instance.compute_odds_to_deadline(1, [])).to eq 0 }
    end

    context 'with deadline after biggest montecarlo data' do
      it { expect(described_class.instance.compute_odds_to_deadline(3, [1, 2, 1])).to eq 1 }
    end

    context 'with deadline after inside montecarlo data' do
      it { expect(described_class.instance.compute_odds_to_deadline(3, [1, 2, 1, 3, 4, 4, 3, 3, 1, 3, 4])).to eq 0.7272727272727273 }
    end
  end
end
