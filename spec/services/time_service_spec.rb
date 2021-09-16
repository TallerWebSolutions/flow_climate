# frozen_string_literal: true

RSpec.describe TimeService, type: :service do
  describe '#compute_working_hours_for_dates' do
    context 'when the dates are in the same day' do
      context 'in different hours' do
        let(:start_date) { Time.zone.local(2018, 2, 13, 14, 0, 0) }
        let(:end_date) { Time.zone.local(2018, 2, 13, 16, 0, 0) }

        it { expect(described_class.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 2 }
      end

      context 'in different minutes' do
        let(:start_date) { Time.zone.local(2018, 2, 13, 14, 0, 0) }
        let(:end_date) { Time.zone.local(2018, 2, 13, 14, 23, 0) }

        it { expect(described_class.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 1 }
      end
    end

    context 'when the dates are in different days' do
      context 'and there is no weekend between the dates' do
        let(:start_date) { Time.zone.local(2018, 2, 13, 14, 0, 0) }
        let(:end_date) { Time.zone.local(2018, 2, 15, 16, 0, 0) }

        it { expect(described_class.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 10 }
      end

      context 'and there is weekend between the dates' do
        let(:start_date) { Time.zone.local(2018, 2, 9, 14, 0, 0) }
        let(:end_date) { Time.zone.local(2018, 2, 13, 16, 0, 0) }

        it { expect(described_class.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 10 }
      end

      context 'and there is less than one minute apart' do
        let(:start_date) { Time.zone.local(2018, 2, 9, 14, 0, 0) }
        let(:end_date) { Time.zone.local(2018, 2, 9, 14, 0, 30) }

        it { expect(described_class.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 0 }
      end

      context 'and there is exactly one minute apart' do
        let(:start_date) { Time.zone.local(2018, 2, 9, 14, 0, 0) }
        let(:end_date) { Time.zone.local(2018, 2, 9, 14, 1, 0) }

        it { expect(described_class.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 0 }
      end
    end

    context 'when the dates are nil' do
      it { expect(described_class.instance.compute_working_hours_for_dates(nil, nil)).to eq 0 }
    end
  end

  describe '#days_between_of' do
    it 'returns the weeks between the dates' do
      start_date = Date.new(2018, 7, 15)
      end_date = Date.new(2018, 7, 18)

      days = described_class.instance.days_between_of(start_date, end_date)

      expect(days).to eq [Date.new(2018, 7, 15), Date.new(2018, 7, 16), Date.new(2018, 7, 17), Date.new(2018, 7, 18)]
    end
  end

  describe '#weeks_between_of' do
    it 'returns the weeks between the dates' do
      start_date = Date.new(2018, 7, 15)
      end_date = Date.new(2018, 8, 21)

      weeks = described_class.instance.weeks_between_of(start_date, end_date)

      expect(weeks).to eq [Date.new(2018, 7, 15), Date.new(2018, 7, 22), Date.new(2018, 7, 29), Date.new(2018, 8, 5), Date.new(2018, 8, 12), Date.new(2018, 8, 19), Date.new(2018, 8, 26)]
    end
  end

  describe '#months_between_of' do
    it 'returns the months between the dates' do
      start_date = Date.new(2018, 7, 15)
      end_date = Date.new(2018, 8, 21)

      months = described_class.instance.months_between_of(start_date, end_date)

      expect(months).to eq [Date.new(2018, 7, 31), Date.new(2018, 8, 31)]
    end
  end

  describe '#add_weeks_to_today' do
    it 'returns the new date x weeks later than today' do
      travel_to Date.new(2018, 8, 30) do
        control_date_5_weeks_later = described_class.instance.add_weeks_to_today(5)

        expect(control_date_5_weeks_later).to eq Date.new(2018, 10, 4)
      end
    end
  end

  describe '#start_of_period_for_date' do
    it 'returns the the start period based on the period variable' do
      start_of_period = described_class.instance.start_of_period_for_date(Time.zone.today)

      expect(start_of_period).to eq Time.zone.today.beginning_of_month

      start_of_period = described_class.instance.start_of_period_for_date(Time.zone.today, 'month')

      expect(start_of_period).to eq Time.zone.today.beginning_of_month

      start_of_period = described_class.instance.start_of_period_for_date(Time.zone.today, 'day')

      expect(start_of_period).to eq Time.zone.today.beginning_of_day

      start_of_period = described_class.instance.start_of_period_for_date(Time.zone.today, 'week')

      expect(start_of_period).to eq Time.zone.today.beginning_of_week

      start_of_period = described_class.instance.start_of_period_for_date(Time.zone.today, 'foo')

      expect(start_of_period).to eq Time.zone.today.beginning_of_month
    end
  end

  describe '#end_of_period_for_date' do
    it 'returns the the end period based on the period variable' do
      start_of_period = described_class.instance.end_of_period_for_date(Time.zone.today)

      expect(start_of_period).to eq Time.zone.today.end_of_month

      start_of_period = described_class.instance.end_of_period_for_date(Time.zone.today, 'month')

      expect(start_of_period).to eq Time.zone.today.end_of_month

      start_of_period = described_class.instance.end_of_period_for_date(Time.zone.today, 'day')

      expect(start_of_period).to eq Time.zone.today.end_of_day

      start_of_period = described_class.instance.end_of_period_for_date(Time.zone.today, 'week')

      expect(start_of_period).to eq Time.zone.today.end_of_week

      start_of_period = described_class.instance.end_of_period_for_date(Time.zone.today, 'foo')

      expect(start_of_period).to eq Time.zone.today.end_of_month
    end
  end

  describe '#beginning_of_semester' do
    it 'returns beginning of semester' do
      travel_to Time.zone.local(2021, 1, 11, 19, 0, 0) do
        date = described_class.instance.beginning_of_semester
        expect(date).to eq Date.new(2021, 1, 1).beginning_of_day

        date = described_class.instance.beginning_of_semester(Date.new(2021, 6, 30))
        expect(date).to eq Date.new(2021, 1, 1).beginning_of_day

        date = described_class.instance.beginning_of_semester(Date.new(2021, 7, 30))
        expect(date).to eq Date.new(2021, 7, 1).beginning_of_day
      end
    end
  end
end
