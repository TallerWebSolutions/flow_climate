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

        it { expect(TimeService.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 16.666666666666668 }
      end
      context 'and there is weekend between the dates' do
        let(:start_date) { Time.zone.local(2018, 2, 9, 14, 0, 0) }
        let(:end_date) { Time.zone.local(2018, 2, 13, 16, 0, 0) }

        it { expect(TimeService.instance.compute_working_hours_for_dates(start_date, end_date)).to eq 16.666666666666668 }
      end
    end
    context 'when the dates are nil' do
      it { expect(TimeService.instance.compute_working_hours_for_dates(nil, nil)).to eq 0 }
    end
  end
end
