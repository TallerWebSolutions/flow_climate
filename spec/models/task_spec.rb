# frozen_string_literal: true

RSpec.describe Task, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :demand }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :created_date }
  end

  context 'callbacks' do
    describe '#compute_time_to_deliver' do
      context 'with end date' do
        it 'defines the seconds to complete' do
          task = Fabricate :task, created_date: 2.days.ago, end_date: Time.zone.now
          expect(task.seconds_to_complete).not_to eq 0
        end
      end

      context 'without end date' do
        it 'does not define the seconds to complete' do
          task = Fabricate :task, created_date: 2.days.ago, end_date: nil
          expect(task.seconds_to_complete).to eq nil
        end
      end
    end
  end
end
