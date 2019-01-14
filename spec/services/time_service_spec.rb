# frozen_string_literal: true

RSpec.describe TimeService, type: :service do
  describe '#compute_working_hours_for_dates' do
    context 'when the dates are in the same day' do
      context 'in different hours' do
        let(:start_date) { Time.zone.local(2018, 2, 13, 14, 0, 0) }
        let(:end_date) { Time.zone.local(2018, 2, 13, 16, 0, 0) }
        it { expect(TimeService.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 2 }
      end
      context 'in different minutes' do
        let(:start_date) { Time.zone.local(2018, 2, 13, 14, 0, 0) }
        let(:end_date) { Time.zone.local(2018, 2, 13, 14, 23, 0) }
        it { expect(TimeService.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 1 }
      end
    end
    context 'when the dates are in different days' do
      context 'and there is no weekend between the dates' do
        let(:start_date) { Time.zone.local(2018, 2, 13, 14, 0, 0) }
        let(:end_date) { Time.zone.local(2018, 2, 15, 16, 0, 0) }

        it { expect(TimeService.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 14 }
      end
      context 'and there is weekend between the dates' do
        let(:start_date) { Time.zone.local(2018, 2, 9, 14, 0, 0) }
        let(:end_date) { Time.zone.local(2018, 2, 13, 16, 0, 0) }

        it { expect(TimeService.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 14 }
      end
    end
    context 'when the dates are nil' do
      it { expect(TimeService.instance.compute_working_hours_for_dates(nil, nil)).to eq 0 }
    end
  end

  describe '#weeks_between_of' do
    it 'returns the weeks between the dates' do
      start_date = Date.new(2018, 7, 15)
      end_date = Date.new(2018, 8, 21)

      weeks_year = TimeService.instance.weeks_between_of(start_date, end_date)

      expect(weeks_year).to eq [Date.new(2018, 7, 9), Date.new(2018, 7, 16), Date.new(2018, 7, 23), Date.new(2018, 7, 30), Date.new(2018, 8, 6), Date.new(2018, 8, 13)]
    end
  end

  describe '#months_between_of' do
    it 'returns the months between the dates' do
      start_date = Date.new(2018, 7, 15)
      end_date = Date.new(2018, 8, 21)

      weeks_year = TimeService.instance.months_between_of(start_date, end_date)

      expect(weeks_year).to eq [Date.new(2018, 7, 1), Date.new(2018, 8, 1)]
    end
  end

  describe '#add_weeks_to_today' do
    before { travel_to Date.new(2018, 8, 30) }
    after { travel_back }
    it 'returns the new date x weeks later than today' do
      control_date_5_weeks_later = TimeService.instance.add_weeks_to_today(5)

      expect(control_date_5_weeks_later).to eq Date.new(2018, 10, 4)
    end
  end

  describe '#limit_date_to_period' do
    before { travel_to Date.new(2018, 8, 30) }
    after { travel_back }

    context 'for period all' do
      it { expect(TimeService.instance.limit_date_to_period('all')).to be_nil }
    end

    context 'for period quarter' do
      it { expect(TimeService.instance.limit_date_to_period('quarter')).to be_within(1.minute).of(3.months.ago) }
    end

    context 'for period month' do
      it { expect(TimeService.instance.limit_date_to_period('month')).to be_within(1.minute).of(1.month.ago) }
    end

    context 'for period week' do
      it { expect(TimeService.instance.limit_date_to_period('week')).to be_within(1.minute).of(1.week.ago) }
    end

    context 'for period nil' do
      it { expect(TimeService.instance.limit_date_to_period(nil)).to be_within(1.minute).of(1.week.ago) }
    end
  end
end
