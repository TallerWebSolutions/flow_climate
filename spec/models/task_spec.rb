# frozen_string_literal: true

RSpec.describe Task do
  context 'associations' do
    it { is_expected.to belong_to :demand }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :created_date }
  end

  context 'scopes' do
    describe '.finished' do
      it 'returns the finished tasks ordered by end_date' do
        discarded_demand = Fabricate :demand, discarded_at: 4.days.ago
        first_task = Fabricate :task, created_date: 2.days.ago, end_date: 1.day.ago
        second_task = Fabricate :task, created_date: 3.days.ago, end_date: 2.days.ago
        Fabricate :task, created_date: 2.days.ago, end_date: nil
        Fabricate :task, demand: discarded_demand, created_date: 3.days.ago, end_date: 2.days.ago

        expect(described_class.finished(Time.zone.now)).to eq [second_task, first_task]
        expect(described_class.finished(27.hours.ago)).to eq [second_task]
      end
    end

    describe '.open' do
      it 'returns the open tasks ordered by created_date' do
        discarded_demand = Fabricate :demand, discarded_at: 4.days.ago
        first_task = Fabricate :task, created_date: 2.days.ago, end_date: nil
        second_task = Fabricate :task, created_date: 3.days.ago, end_date: nil
        Fabricate :task, demand: discarded_demand, created_date: 3.days.ago, end_date: nil
        Fabricate :task, created_date: 2.days.ago, end_date: 1.day.ago

        expect(described_class.open(Time.zone.now)).to eq [second_task, first_task]
        expect(described_class.open(54.hours.ago)).to eq [second_task]
      end
    end

    describe '.not_discarded_until' do
      it 'returns the not discarded tasks until date' do
        discarded_demand = Fabricate :demand, discarded_at: 4.days.ago
        first_task = Fabricate :task, demand: discarded_demand, created_date: 2.days.ago, end_date: nil
        second_task = Fabricate :task, created_date: 3.days.ago, end_date: 2.days.ago, discarded_at: nil

        expect(described_class.not_discarded_until(Time.zone.now)).to eq [second_task]
        expect(described_class.not_discarded_until(5.days.ago)).to match_array [first_task, second_task]
      end
    end

    describe '.opened_between' do
      it 'returns the opened tasks between the given dates' do
        discarded_demand = Fabricate :demand, discarded_at: 4.days.ago
        first_task = Fabricate :task, created_date: 2.days.ago, end_date: nil
        second_task = Fabricate :task, created_date: 3.days.ago, end_date: nil
        Fabricate :task, demand: discarded_demand, created_date: 3.days.ago, end_date: nil
        Fabricate :task, created_date: 4.days.ago, end_date: 1.day.ago

        expect(described_class.opened_between(3.days.ago, 2.days.ago)).to match_array [first_task, second_task]
      end
    end

    describe '.finished_between' do
      it 'returns the finished tasks between the given dates' do
        discarded_demand = Fabricate :demand, discarded_at: 4.days.ago
        first_task = Fabricate :task, created_date: 4.days.ago, end_date: 3.days.ago
        second_task = Fabricate :task, created_date: 3.days.ago, end_date: 2.days.ago
        Fabricate :task, demand: discarded_demand, created_date: 3.days.ago, end_date: nil
        Fabricate :task, created_date: 2.days.ago, end_date: 1.day.ago

        expect(described_class.finished_between(3.days.ago, 2.days.ago)).to match_array [first_task, second_task]
      end
    end
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
          expect(task.seconds_to_complete).to be_nil
        end
      end
    end
  end

  describe '#partial_completion_time' do
    context 'with a finished demand' do
      it 'returns the time to complete' do
        travel_to Time.zone.local(2022, 2, 22, 10, 0, 0) do
          task = Fabricate :task, created_date: 2.days.ago, end_date: 12.hours.ago

          expect(task.partial_completion_time).to eq 129_600
        end
      end
    end

    context 'with a not finished demand' do
      it 'returns the difference between the creation date and the current time' do
        travel_to Time.zone.local(2022, 2, 22, 10, 0, 0) do
          task = Fabricate :task, created_date: 2.days.ago

          expect(task.partial_completion_time).to eq 172_800
        end
      end
    end
  end

  describe '#task_type' do
    it 'returns the work item type name' do
      task = Fabricate :task
      expect(task.task_type).to eq task.work_item_type.name
    end
  end
end
