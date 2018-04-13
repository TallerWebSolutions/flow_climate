# frozen_string_literal: true

RSpec.describe CollectionsService do
  describe '.find_nearest' do
    let(:array) { [7.days.ago.to_date, 3.days.ago.to_date, 15.days.from_now.to_date, 17.days.from_now.to_date] }
    context 'when the near element is over the target value' do
      let(:target) { 2.days.ago.to_date }
      it { expect(CollectionsService.find_nearest(array, target)).to eq 3.days.ago.to_date }
    end
    context 'when the near element is under the target value' do
      let(:target) { 4.days.ago.to_date }
      it { expect(CollectionsService.find_nearest(array, target)).to eq 3.days.ago.to_date }
    end
    context 'when the near element is the target value' do
      let(:target) { 7.days.ago.to_date }
      it { expect(CollectionsService.find_nearest(array, target)).to eq 7.days.ago.to_date }
    end
    context 'when the target value is exactly in the middle' do
      let(:target) { 16.days.from_now.to_date }
      it { expect(CollectionsService.find_nearest(array, target)).to eq 15.days.from_now.to_date }
    end
  end
end
