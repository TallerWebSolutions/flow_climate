# frozen_string_literal: true

RSpec.describe TasksList, type: :value_object do
  describe '#delivered_lead_time_p65' do
    context 'with data' do
      it 'returns the completion time p65 for the given tasks list' do
        travel_to Time.zone.local(2022, 3, 25, 10, 0, 0) do
          Fabricate :task, created_date: 2.days.ago, end_date: 1.day.ago
          Fabricate :task, created_date: 4.days.ago, end_date: 1.day.ago
          Fabricate :task, created_date: 7.days.ago, end_date: 2.days.ago
          Fabricate :task, created_date: 1.day.ago, end_date: nil

          tasks_list = described_class.new(4, 3, true, 1, Task.all)
          expect(tasks_list.delivered_lead_time_p65).to eq 311_040
        end
      end
    end

    context 'without data' do
      it 'returns 0' do
        tasks_list = described_class.new(0, 0, true, 1, Task.all)
        expect(tasks_list.delivered_lead_time_p65).to eq 0
      end
    end
  end

  describe '#delivered_lead_time_p80' do
    context 'with data' do
      it 'returns the completion time p80 for the given tasks list' do
        travel_to Time.zone.local(2022, 3, 25, 10, 0, 0) do
          Fabricate :task, created_date: 2.days.ago, end_date: 1.day.ago
          Fabricate :task, created_date: 4.days.ago, end_date: 1.day.ago
          Fabricate :task, created_date: 7.days.ago, end_date: 2.days.ago
          Fabricate :task, created_date: 1.day.ago, end_date: nil

          tasks_list = described_class.new(4, 3, true, 1, Task.all)
          expect(tasks_list.delivered_lead_time_p80).to eq 362_880
        end
      end
    end

    context 'without data' do
      it 'returns 0' do
        tasks_list = described_class.new(0, 0, true, 1, Task.all)
        expect(tasks_list.delivered_lead_time_p80).to eq 0
      end
    end
  end

  describe '#delivered_lead_time_p95' do
    context 'with data' do
      it 'returns the completion time p95 for the given tasks list' do
        travel_to Time.zone.local(2022, 3, 25, 10, 0, 0) do
          Fabricate :task, created_date: 2.days.ago, end_date: 1.day.ago
          Fabricate :task, created_date: 4.days.ago, end_date: 1.day.ago
          Fabricate :task, created_date: 7.days.ago, end_date: 2.days.ago
          Fabricate :task, created_date: 1.day.ago, end_date: nil

          tasks_list = described_class.new(4, 3, true, 1, Task.all)
          expect(tasks_list.delivered_lead_time_p95).to eq 414_720
        end
      end
    end

    context 'without data' do
      it 'returns 0' do
        tasks_list = described_class.new(0, 0, true, 1, Task.all)
        expect(tasks_list.delivered_lead_time_p95).to eq 0
      end
    end
  end

  describe '#in_progress_lead_time_p65' do
    context 'with data' do
      it 'returns the completion time p65 for the given tasks list' do
        travel_to Time.zone.local(2022, 3, 25, 10, 0, 0) do
          Fabricate :task, created_date: 2.days.ago, end_date: nil
          Fabricate :task, created_date: 4.days.ago, end_date: nil
          Fabricate :task, created_date: 7.days.ago, end_date: nil
          Fabricate :task, created_date: 1.day.ago, end_date: 1.hour.ago

          tasks_list = described_class.new(4, 1, true, 1, Task.all)
          expect(tasks_list.in_progress_lead_time_p65).to eq 423_360
        end
      end
    end

    context 'without data' do
      it 'returns 0' do
        tasks_list = described_class.new(0, 0, true, 1, Task.all)
        expect(tasks_list.in_progress_lead_time_p65).to eq 0
      end
    end
  end

  describe '#in_progress_lead_time_p80' do
    context 'with data' do
      it 'returns the completion time p80 for the given tasks list' do
        travel_to Time.zone.local(2022, 3, 25, 10, 0, 0) do
          Fabricate :task, created_date: 2.days.ago, end_date: nil
          Fabricate :task, created_date: 4.days.ago, end_date: nil
          Fabricate :task, created_date: 7.days.ago, end_date: nil
          Fabricate :task, created_date: 1.day.ago, end_date: 1.hour.ago

          tasks_list = described_class.new(4, 3, true, 1, Task.all)
          expect(tasks_list.in_progress_lead_time_p80).to eq 501_120
        end
      end
    end

    context 'without data' do
      it 'returns 0' do
        tasks_list = described_class.new(0, 0, true, 1, Task.all)
        expect(tasks_list.in_progress_lead_time_p80).to eq 0
      end
    end
  end

  describe '#in_progress_lead_time_p95' do
    context 'with data' do
      it 'returns the completion time p95 for the given tasks list' do
        travel_to Time.zone.local(2022, 3, 25, 10, 0, 0) do
          Fabricate :task, created_date: 2.days.ago, end_date: nil
          Fabricate :task, created_date: 4.days.ago, end_date: nil
          Fabricate :task, created_date: 7.days.ago, end_date: nil
          Fabricate :task, created_date: 1.day.ago, end_date: 1.hour.ago

          tasks_list = described_class.new(4, 3, true, 1, Task.all)
          expect(tasks_list.in_progress_lead_time_p95).to eq 578_880
        end
      end
    end

    context 'without data' do
      it 'returns 0' do
        tasks_list = described_class.new(0, 0, true, 1, Task.all)
        expect(tasks_list.in_progress_lead_time_p95).to eq 0
      end
    end
  end
end
